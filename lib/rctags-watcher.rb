require "logger"
require "rb-inotify"
require_relative "rctags-watcher/configuration"
require_relative "rctags-watcher/project_watcher"
require_relative "rctags-watcher/job_scheduler"
require_relative "rctags-watcher/worker"

class RctagsWatcher < Logger::Application

    def initialize(config_files = [], arguments)
        @config = nil
        @program_arguments = arguments
        @watchers = {}
        @notifier = INotify::Notifier.new

        super('RctagsWatcher')

        load_configuration config_files, arguments
        setup_logging

        @job_scheduler = JobScheduler.new
        @job_scheduler.logger = @logger

        @worker = Worker.new(@job_scheduler.queue)
        @worker.logger = @logger

        @job_scheduler.worker = @worker
    end

    def run
        install_watchers
        @notifier.run
    end 

    def stop
        @notifier.stop
        @worker.stop
    end

    def schedule_ctags_job(project_name, changed_path)
        log DEBUG, "Activity detected on #{project_name} - #{changed_path}"

        if !@job_scheduler.can_schedule?
            return;
        end

        project_settings = @config.projects[project_name]
        ctags_settings = @config.ctags_settings
        job_settings = {
            :project_settings => project_settings,
            :ctags_settings => ctags_settings
        }

        job_params = { :name => project_name, 
                       :change_path => changed_path,
                       :settings => job_settings
        }
        @job_scheduler.schedule job_params
    end


    private

    def setup_logging
        if @config.log_to_stdout?
            @logger = Logger.new(STDOUT)
        elsif @config.log_to_stderr?
            @logger = Logger.new(STDERR)
        else
            log_path = @config.log_path
            @logger = Logger.new(log_path)
        end

        case @config.log_level
        when 'DEBUG'
            log_level = Logger::DEBUG
        when 'INFO'
            log_level = Logger::INFO
        when 'WARN'
            log_level = Logger::WARN
        when 'ERROR'
            log_level = Logger::ERROR
        when 'FATAL'
            log_level = Logger::FATAL
        when 'UNKNOWN'
            log_level = Logger::UNKNOWN
        else
            raise "Unknown log level #{@config.log_level}"
        end
        @logger.level = log_level

    end

    def install_watchers
        @config.projects.each do |project_name, settings|
            watcher = ProjectWatcher.new(project_name, settings, @notifier)
            @watchers[project_name] = watcher
            watcher.add_observer self, :schedule_ctags_job
            watcher.watch
        end
    end

    def load_configuration(config_files, runtime_arguments)
        @config = Configuration.new(config_files)
        @config.load
    end
end
