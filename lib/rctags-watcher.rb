require "logger"
require "rb-inotify"
require_relative "configuration"
require_relative "project_watcher"

class RctagsWatcher < Logger::Application

    def initialize(config_files = [], arguments)
        @config = nil
        @program_arguments = arguments
        @watchers = {}
        @notifier = INotify::Notifier.new

        super 'RctagsWatcher'
        # Create job queue for each project
        # Create worker thread for reach queue
        load_configuration config_files, arguments
    end

    def run
        setup_logging
        install_watchers
        # Start workers threads
        @notifier.run
    end 

    def stop
        @notifier.stop
        # Stop/join worker threads
        # Empty queues
    end

    def schedule_ctags_job(project_name, project_path)
        # Check if job is already scheduled
        # Add job to queue
        log(DEBUG, "Activity detected on #{project_name} - #{project_path}")
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
