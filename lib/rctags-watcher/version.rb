# %license%
module RctagsWatcherVersion
    version_file_path = File.dirname(__FILE__) + '/../VERSION'
    version = 'dev'
    if File.file? version_file_path
        File.open version_file_path, 'r' do |f| 
            version = f.read
        end
    end
    VERSION = version
end
