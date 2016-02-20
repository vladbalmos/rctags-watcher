require "yaml"

class Configuration

    def initialize(config_files, misc_settings = {})
        @config_files = config_files
        @misc_settings = misc_settings
        @configuration_is_loaded = false
    end

    def load
        if @configuration_is_loaded
            return @config
        end

        @config = load_default
        @config_files.each do |file|
            cfg = YAML.load_file(file)
            @config.merge!(cfg)
        end

        @configuration_is_loaded = true
        return @config
    end

    def log_to_stdout?
        return @config['logging']['log_destination'] == 'STDOUT'
    end

    def log_to_stderr?
        return @config['logging']['log_destination'] == 'STDERR'
    end

    def get_log_path
        return @config['logging']['log_destination']
    end

    def log_level
        return @config['logging']['level']
    end

    private
    def load_default
        default = {
            'logging' => {
                'level' => 'DEBUG',
                'log_destination' => 'STDERR'
            },
            'dirs' => []
        }
        return default
    end
end
