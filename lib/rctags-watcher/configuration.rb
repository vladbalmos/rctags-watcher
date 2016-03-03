# The MIT License (MIT)
# 
# Copyright (c) 2016 Vlad Balmos
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
