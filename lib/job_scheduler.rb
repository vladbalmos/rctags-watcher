require_relative "logger_helper"
require "logger"

class JobScheduler

    include LoggerHelper
    attr_reader :queue

    def initialize
        @queue = Queue.new
    end

    def can_schedule?
        return @queue.empty?
    end

    def schedule(job_params)
        log(Logger::INFO, "Scheduling ctags job for #{job_params[:name]}")

        job = make_job job_params
        @queue << job
    end

    def make_job(job_params)
        ctags_settings = job_params[:settings][:ctags_settings]
        project_settings = job_params[:settings][:project_settings]

        if !ctags_settings.nil? and !ctags_settings[:bin].nil?
            ctags_binary = ctags_settings[:bin]
        else
            ctags_binary = 'ctags'
        end

        recursive_flag = '-R' unless project_settings[:recursive] == false

        scan_path = project_settings["path"]

        tags_filename = project_settings['tags_filename'].nil? ? 'tags' : project_settings["tags_filename"]
        tags_file_path = project_settings['path'] + "/#{tags_filename}"

        command = "#{ctags_binary} #{recursive_flag} #{scan_path} -f #{tags_file_path} 2>&1"
        job = {
            :name => job_params[:name] + '_ctags_job',
            :command => command
        }
        return job
    end

end
