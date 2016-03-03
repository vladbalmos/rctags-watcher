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

require_relative "file_matcher"
require "rb-inotify"
require "observer"

##
# Wraps the rb-inotify API.
class ProjectWatcher
    include Observable

    def initialize(name, settings, notifier)
        @notifier = notifier
        @name = name
        @path = File.expand_path settings['path']
        @recursive_watch = settings['recursive'] || false

        unless File.directory? @path
            raise "Project path invalid for project #{@name}: #{@path}"
        end

        if settings['pattern'].nil?
            raise "Missing files pattern for project #{@name}"
        end

        @file_patterns = settings['pattern'].split(' ').map { |item| item = item.strip }
    end

    def watch
        notifier_arguments = [@path, :create, :modify, :delete, :move]
        if @recursive_watch
            notifier_arguments << :recursive
        end

        @notifier.watch(*notifier_arguments) { |event| 
            process_filesystem_event event
        }
    end

    private 

    ##
    # Checks to see if the changed file matches the configured file pattern
    # and notifies any observers.
    def process_filesystem_event(event)
        absolute_filepath = event.absolute_name

        @file_patterns.each do |pattern|
            if FileMatcher.file_matches_pattern? absolute_filepath, pattern
                changed
                notify_observers @name, @path
            end
        end
        
    end
end
