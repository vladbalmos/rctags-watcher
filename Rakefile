require "rake/clean"

CLEAN << 'build'

task :default => [:test]

task :test do
    ruby "test/ts_all.rb"
end

task :test_unit do
    ruby "test/ts_unit.rb"
end

task :build_gem do
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
