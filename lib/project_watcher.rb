require_relative "directory_iterator"
require "rb-inotify"

class ProjectWatcher

    def initialize(name, settings, notifier)
        @notifier = notifier
        @name = name
        @path = File.expand_path(settings['path'])
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
        puts absolute_filepath
        puts @file_patterns
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
