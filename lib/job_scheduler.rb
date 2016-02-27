require_relative "logger_helper"
require "logger"

class JobScheduler

    include LoggerHelper
    attr_reader :queue
    attr_accessor :worker

    def initialize
        @queue = Queue.new
        @worker = nil
    end

    def can_schedule?
        if !@worker.nil? and @worker.job_running?
            return false
        end

        return @queue.empty?
    end

    def schedule(job_params)
        log(Logger::INFO, "Scheduling ctags job for #{job_params[:name]}")

        begin
            job = make_job job_params
        rescue RuntimeError => e
            log(Logger::ERROR, e.message)
            return false
        end
        @queue << job
        return true
    end

    def make_job(job_params)
        ctags_settings = job_params[:settings][:ctags_settings]
        project_settings = job_params[:settings][:project_settings]

        if !ctags_settings.nil? and !ctags_settings[:bin].nil?
            ctags_binary = ctags_settings[:bin]
        else
            ctags_binary = 'ctags'
        end

        scan_path = File.expand_path project_settings["path"]

        raise "Project path does not exist: #{scan_path}" unless File.directory? scan_path

        tags_filename = project_settings['tags_filename'].nil? ? 'tags' : project_settings["tags_filename"]
        ctags_languages = prepare_ctags_languages project_settings["ctags_languages"]

        job = {
            :name => job_params[:name] + '_ctags_job',
            :ctags_binary => ctags_binary,
            :scan_path => scan_path,
            :tags_filename => tags_filename,
            :recursive => project_settings['recursive'],
            :ctags_languages => ctags_languages
        }
        return job
    end

    def prepare_ctags_languages(languages)
        unless languages
            return
        end
        lang_array = languages.split(',').compact
        lang_array.collect! { |item| item.strip }

        return lang_array
    end

end
