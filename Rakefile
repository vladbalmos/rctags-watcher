require "rake/clean"

CLEAN << 'build'

task :default => [:test]

task :test do
    ruby "test/ts_all.rb"
end

task :test_unit do
    ruby "test/ts_unit.rb"
end

task :setup_functional_tests => :clean do
    functional_test_dir = 'build/functional-test'
    full_project_path = nil

    mkdir_p functional_test_dir

    cp 'data/fixtures/functional-test.conf', "#{functional_test_dir}/rctags-watcher.conf"

    Dir.chdir functional_test_dir do 
        sh 'git clone --depth=1 https://github.com/vladbalmos/travelpsdk'
        full_project_path = File.expand_path "travelpsdk"
        puts full_project_path

        sh "sed -i s,_path_to_project_,#{full_project_path},g rctags-watcher.conf"
    end

    ENV['TEST_CONFIG_FILE'] = "#{functional_test_dir}/rctags-watcher.conf"
    ENV['TEST_PHP_FILE'] = "#{full_project_path}/src/Flight/Search.php"
    ENV['TEST_TAGS_FILE'] = "#{full_project_path}/tags"
end

task :test_functional_foreground => :setup_functional_tests do
    ruby "test/tc_functional_foreground.rb"
end

task :test_functional_daemon => :setup_functional_tests do
    ruby "test/tc_functional_daemon.rb"
end

task :test_functional do
    Rake::Task['test_functional_foreground'].invoke
    Rake::Task['test_functional_daemon'].invoke
end

task :test_all do
    Rake::Task['test'].invoke
    Rake::Task['test_functional'].invoke
end

task :build_gem => :test_all do
    gemspec = File.basename(File.dirname __FILE__) + '.gemspec'
    mkdir_p 'build/gem'
    output = `gem build #{gemspec}`
    if $?.exitstatus != 0
        abort "Unable to build gem: #{$?.exitstatus}"
    end

    puts output
    lines = output.split($/)[-1].split(':')
    gem_file = lines[1].strip

    mv gem_file, 'build/gem/'
end
