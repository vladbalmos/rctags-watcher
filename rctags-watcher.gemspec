require 'rake'

files = []

Gem::Specification.new do |s|
    s.name        = 'rctags-watcher'
    s.version     = '%version'
    s.summary     = "(re)Generate a \"tags\" file using \"ctags\" when a project source code changes"
    s.description = <<EOT
A small utility which uses inotify to detect changes in a directory and run 
ctags on that directory.
Useful when using VIM as an IDE.
EOT
    s.authors     = ["Vlad Balmos"]
    s.email       = 'vladbalmos@yahoo.com'
    s.files       = files
    s.homepage    =
    'https://github.com/vladbalmos/rctags-watcher'
    s.license       = 'MIT'
    s.platform    = Gem::Platform::CURRENT
    s.executables << 'rctags-watcher'
end
