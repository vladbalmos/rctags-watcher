# foreach directory in configuration
    # install filesystem watch
# start event loop

require "logger"
require_relative "configuration"

class RctagsWatcher < Logger::Application

    def initialize(config_files = [], arguments)
        @config = nil
        @program_arguments = arguments
        @watchers = {}

        super('RctagsWatcher')
        load_configuration config_files, arguments
    end

    def run
        setup_logging
        install_watchers
        return 0
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
            watcher = ProjectWatcher.new(project_name, settings)
            @watchers[project_name] = watcher

            watcher.watch
        end
    end

    def load_configuration(config_files, runtime_arguments)
        @config = Configuration.new(config_files)
        @config.load
    end
end
