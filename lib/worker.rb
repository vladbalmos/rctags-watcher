require_relative "logger_helper"
require "logger"
require "thread"

class Worker < Thread

    include LoggerHelper

    def initialize(work_queue)
        super(work_queue, &method(:work))
        @job_state = nil
        @job_state_sem = Mutex.new
        @break_loop = false
        @break_loop_sem = Mutex.new
    end

    def work(work_queue)
        while job = work_queue.pop
            set_job_state :running
            log(Logger::DEBUG, "Running command #{job[:command]}")
            result = system job[:command]

            if result.nil?
                exit_status = $?.exitstatus.to_s
                log(Logger::ERROR, "Unable to execute job command. Exit status: #{exit_status}")
            elsif result == false
                exit_status = $?.exitstatus.to_s
                log(Logger::ERROR, "Job command was unsuccessful. Exit status: #{exit_status}")
            else
                log(Logger::INFO, "Job command executed successfully.")
            end
            set_job_state :not_running
            break if break_loop?
        end
    end

    def stop
        if job_running?
            # If a job is running we set a "break loop" flag so we can do a clean exit
            activate_break_loop_flag
            join
            return
        end
        join 1
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
