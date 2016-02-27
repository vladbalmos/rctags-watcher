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
