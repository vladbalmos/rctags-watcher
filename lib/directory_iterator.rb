class DirectoryIterator

    def initialize(path)
        @base_path = path
    end

    def each_subdir
        pattern = @base_path + "/**/*"
        yield File.expand_path(@base_path)
        Dir.glob(pattern) do |dir|
            if File.directory? dir
                yield File.expand_path(dir) if block_given?
            end
        end
    end
end
