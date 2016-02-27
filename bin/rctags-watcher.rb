#!/usr/bin/env ruby

require_relative "../lib/rctags-watcher" if File.file?((File.dirname __FILE__) + "/../lib/rctags-watcher.rb")
require "rctags-watcher" unless File.file?((File.dirname __FILE__) + "/../lib/rctags-watcher.rb")
require "etc"

CONFIG_FILENAME = 'rctags-watcher.conf'

if __FILE__ == $0
    local_config_file = File.expand_path('~') + '/.' + CONFIG_FILENAME
    global_config_file = Etc.sysconfdir + '/' + CONFIG_FILENAME
    config_files = []

    if File.file? global_config_file
        config_files << global_config_file
    end

    if File.file? local_config_file
        config_files << local_config_file
    end

    app = RctagsWatcher.new(config_files, ARGV)

    begin
        app.start
    rescue SignalException => e
        if Signal.signame(e.signo) == "INT" or Signal.signame(e.signo) == "KILL"
            app.stop
            exit 0
        end

        raise e
    end
end
