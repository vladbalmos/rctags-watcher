# %license%
require_relative "file_matcher"
require "rb-inotify"
require "observer"

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
