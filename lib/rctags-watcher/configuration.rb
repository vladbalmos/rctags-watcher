# %license%
require "yaml"

##
# Merges YAML files to generate the final app configuration.
class Configuration

    ##
    # THe configuration from the files which appear last in the 
    # config_files array gets merged into the configuration loaded
    # from the first items in the array
    def initialize(config_files)
        @config_files = config_files
        @configuration_is_loaded = false
    end

    def load
        if @configuration_is_loaded
            return @config
        end

        @config = load_default
        @config_files.each do |file|
            cfg = YAML.load_file file
            @config.merge! cfg
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

    def log_path
        return @config['logging']['log_destination']
    end

    def log_level
        return @config['logging']['level']
    end

    def projects
        return @config['projects']
    end

    def ctags_settings
        return @config['ctags']
    end

    private
    def load_default
        default = {
            'logging' => {
                'level' => 'DEBUG',
                'log_destination' => 'STDERR'
            },
            'projects' => []
        }
        return default
    end
end
