require_relative "logger_helper"
require "logger"
require "thread"
require "tmpdir"
require "fileutils"

class Worker < Thread

    include LoggerHelper

    def initialize(work_queue)
        super(work_queue, &method(:work))
        @job_state = nil
        @job_state_sem = Mutex.new
        @break_loop = false
        @break_loop_sem = Mutex.new
    end

    def self.make_ctags_command(job_params)
        if job_params.has_key? :test_command
            return job_params[:test_command] # aids in testing
        end

        ctags_binary = job_params[:ctags_binary]
        scan_path = job_params[:scan_path]
        tags_filename = job_params[:tags_filename]

        languages_option = '--languages=' + job_params[:ctags_languages].join(',') if job_params[:ctags_languages].instance_of? Array
        command = "#{ctags_binary}"
        command += " #{languages_option}" if languages_option
        command += " -f #{tags_filename}"
        command += " -R" if job_params[:recursive]
        command += " #{scan_path} 1>/dev/null 2>&1"

        return command
    end

    def work(work_queue)
        while job = work_queue.pop
            set_job_state :running
            command = self.class.make_ctags_command job
            log Logger::DEBUG, "Running command #{command}"

            # Run command in a temporary dir
            Dir.mktmpdir("rctags") do |tmpdir| 
                log Logger::DEBUG, "Created #{tmpdir}"
                Dir.chdir(tmpdir) {
                    log Logger::DEBUG, "Changed current directory to #{tmpdir} before running command"
                    result = system command

                    if result.nil?
                        exit_status = $?.exitstatus.to_s
                        log Logger::ERROR, "Unable to execute job command. Exit status: #{exit_status}"
                        next
                    end

                    if result == false
                        exit_status = $?.exitstatus.to_s
                        log Logger::ERROR, "Job command was unsuccessful. Exit status: #{exit_status}"
                        next
                    end

                    log Logger::INFO, "Job command executed successfully."
                    
                    # Moving the file to its final location
                    tmpsrc =  "#{tmpdir}/#{job[:tags_filename]}"
                    dst = "#{job[:scan_path]}/#{job[:tags_filename]}"
                    FileUtils.mv tmpsrc, dst, :force => true
                    log(Logger::DEBUG, "Moved #{tmpsrc} -> #{dst}")
                }
            end

            set_job_state :not_running
            break if break_loop?
        end
    end

    def stop
        if !job_running?
            join 1
            return
        end

        # If a job is running we set a "break loop" flag so we can do a clean exit
        activate_break_loop_flag
        join
    end

    def job_running?
        @job_state_sem.synchronize do
            return true if @job_state == :running
            return false
        end
    end

    private

    def set_job_state(state)
        if state != :running and state != :not_running
            raise ArgumentError, "Invalid job state given: " + state.to_s
        end

        @job_state_sem.synchronize {
            @job_state = state
        }
    end

    def activate_break_loop_flag
        @break_loop_sem.synchronize {
            @break_loop = true
        }
    end

    def break_loop?
        return @break_loop
    end

end
