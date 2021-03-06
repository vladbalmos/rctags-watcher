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

require "logger"
require "logger-application" unless defined? Logger::Application
require "rb-inotify"
require_relative "rctags-watcher/configuration"
require_relative "rctags-watcher/project_watcher"
require_relative "rctags-watcher/job_scheduler"
require_relative "rctags-watcher/worker"
require_relative "rctags-watcher/version"
require_relative "rctags-watcher/control"

##
# The main application class.
# Application flow:
#   1. Load the yaml configuration
#   2. Setup logging
#   3. Create the worker thread and the job queue
#   4. Install inotify watchers on the directories specified in the configuration files
#   5. Start the inotify event loop
class RctagsWatcher < Logger::Application

    include RctagsWatcherVersion

    def initialize(config_files = [])
        @config = nil
        @watchers = {}
        @notifier = INotify::Notifier.new

        super('RctagsWatcher')

        load_configuration config_files
        setup_logging

        @job_scheduler = JobScheduler.new
        @job_scheduler.logger = logger

        @worker = Worker.new(@job_scheduler.queue)
        @worker.logger = logger

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

        unless @job_scheduler.can_schedule?
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

    ##
    # Return a handle to the Control object
    def self.initialize_control_component(socket_path)
        control = Control.new(socket_path)
        return control
    end

    private

    def setup_logging
        if @config.log_to_stdout?
            logdev = STDOUT
        elsif @config.log_to_stderr?
            logdev = STDERR
        else
            logdev = @config.log_path
        end

        set_log logdev

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
        level = log_level
    end

    def install_watchers
        @config.projects.each do |project_name, settings|
            watcher = ProjectWatcher.new(project_name, settings, @notifier)
            @watchers[project_name] = watcher
            watcher.add_observer self, :schedule_ctags_job
            watcher.watch
        end
    end

    def load_configuration(config_files)
        @config = Configuration.new(config_files)
        @config.load
    end
end
