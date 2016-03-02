#!/usr/bin/env ruby

require_relative "../lib/rctags-watcher" if File.file?((File.dirname __FILE__) + "/../lib/rctags-watcher.rb")
require "rctags-watcher" unless File.file?((File.dirname __FILE__) + "/../lib/rctags-watcher.rb")
require "etc"
require "optparse"
require "ostruct"

DEFAULT_CONFIG_FILENAME = 'rctags-watcher.conf'


# Parse command line arguments
commandline_options = OpenStruct.new
commandline_options.config_file = nil

opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: rctags-watcher.rb [options.]"
    opts.separator ""
    opts.separator "Options:"

    opts.on('-c', '--config CONFIG_FILE',
            'Use a custom configuration file.') do |config_file|
        commandline_options.config_file = File.expand_path config_file

        unless File.file? commandline_options.config_file
            abort "Configuration file not found!"
        end
    end

    opts.on('-v', '--version',
            'Show the version.') do 
        puts RctagsWatcher::VERSION
        exit 0
    end
end

opt_parser.parse!(ARGV)

config_files = []

unless commandline_options.config_file.nil?
    config_files << commandline_options.config_file
else
    local_config_file = File.expand_path('~') + '/.' + DEFAULT_CONFIG_FILENAME
    global_config_file = Etc.sysconfdir + '/' + DEFAULT_CONFIG_FILENAME

    if File.file? global_config_file
        config_files << global_config_file
    end

    if File.file? local_config_file
        config_files << local_config_file
    end
end

app = RctagsWatcher.new(config_files)

begin
    app.start
rescue SignalException => e
    if Signal.signame(e.signo) == "INT" or Signal.signame(e.signo) == "KILL"
        app.stop
        exit 0
    end

    raise e
end
