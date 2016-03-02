# %license% 

module FileMatcher

    def self.file_matches_pattern?(filename, pattern)
        if filename.length == 0
            return false
        end
        r = make_regex pattern
        match = r.match filename

        return !match.nil?
    end

    def self.make_regex(pattern)
        escaped = Regexp.escape(pattern).gsub('\*', '.*?')
        r = Regexp.new("^#{escaped}$")
        return r
    end

end
