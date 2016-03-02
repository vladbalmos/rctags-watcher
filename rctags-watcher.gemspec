require 'rake'

module RctagsWatcherGemSpec

    tag = `git describe --tags --long`
    tag = tag.split('-')

    if ENV['VERSION'].nil?
        version = tag[0] + '.' + tag[1]
    else
        version = ENV['VERSION']
    end

    if ENV['IS_PRERELEASE']
        version = version + "-" + tag[2]
    end

    File.open('lib/VERSION', 'w') { |f| f.write version + $/ }

    files = FileList['bin/rctags-watcher.rb',
                     'lib/**/*.rb',
                     'data/**/*',
                     'Gemfile',
                     'LICENSE',
                     'Rakefile',
                     __FILE__,
                     'README.md',
                     'test/**/*.rb'].to_a

    Gem::Specification.new do |s|
        s.name        = 'rctags-watcher'
        s.version     = version
        s.summary     = "(re)Generate a \"tags\" file using \"ctags\" when a project source code changes"
        s.description = <<EOT
A small utility which uses inotify to detect changes in a directory and run 
ctags on that directory.
Useful when using VIM as an IDE.
EOT
        s.authors     = ["Vlad Balmos"]
        s.email       = 'vladbalmos@yahoo.com'
        s.files       = files
        s.homepage    = 'https://github.com/vladbalmos/rctags-watcher'
        s.license     = 'MIT'
        s.platform    = Gem::Platform::CURRENT
        s.executables << 'rctags-watcher.rb'
        s.add_runtime_dependency 'rb-inotify', '= 0.9.7'
        s.required_ruby_version = '>= 2.1.0'

        puts s.version
    end

end
