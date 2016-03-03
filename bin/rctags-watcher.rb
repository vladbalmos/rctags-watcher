#!/usr/bin/env ruby

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

require_relative "../lib/rctags-watcher" if File.file?((File.dirname __FILE__) + "/../lib/rctags-watcher.rb")
require "rctags-watcher" unless File.file?((File.dirname __FILE__) + "/../lib/rctags-watcher.rb")
require "etc"
require "optparse"
require "ostruct"

DEFAULT_CONFIG_FILENAME = 'rctags-watcher.conf'


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
