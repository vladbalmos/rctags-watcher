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
        @file_patterns = nil

        if !File.directory? @path
            raise "Project path invalid for project #{@name}"
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


if __FILE__ == $0
    notifier = INotify::Notifier.new
    settings = {
        'path' => '~/Development/zazat/site',
        'recursive' => true,
        'pattern' => '*.php'
    }

    watcher = ProjectWatcher.new('zazat', settings, notifier)
    watcher.watch

    notifier.run
end