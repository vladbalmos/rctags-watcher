# The MIT License (MIT)
# 
# Copyright (c) 2016 Vlad Balmos
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require_relative "../lib/rctags-watcher/file_matcher"
require "test/unit"

class TestFileMatcher < Test::Unit::TestCase

    def test_doesnt_match_empty_string
        do_match_assertions [''], '*', false
    end

    def test_match_all_files
        filenames = ['my-file',
                     'var/www/index.html',
                     '/etc/passwd',
                    ]
        pattern = '*'

        do_match_assertions filenames, pattern, true
    end

    def test_match_php_files
        filenames = ['/var/www/index.php',
                     '/var/www/php/file.php',
                     '.php',
                    ]
        pattern = '*.php'

        do_match_assertions filenames, pattern, true
    end

    def test_doesnt_match_php_files
        filenames = ['not a php file',
                     'php',
                     'php.out',
                    ]
        pattern = '*.php'

        do_match_assertions filenames, pattern, false
    end

    def do_match_assertions(filenames, pattern, expectation)

        filenames.each do |filename|
            expected = FileMatcher.file_matches_pattern?(filename, pattern)
            assert_equal expectation, expected
        end

    end

end
