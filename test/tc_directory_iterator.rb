require_relative "../lib/directory_iterator"
require "test/unit"

class TestDirectoryIterator < Test::Unit::TestCase

    def test_iterates_over_each_subdir
        dir_iterator = DirectoryIterator.new("data/fixtures/dir-iterator")

        list = []
        dir_iterator.each_subdir { |dir|
            list << dir
        }

        expected_base_path = File.expand_path("data/fixtures/dir-iterator")

        assert_equal true, list.include?(expected_base_path)
        assert_equal true, list.include?(expected_base_path + '/sub-folder-one')
        assert_equal true, list.include?(expected_base_path + '/sub-folder-one/subfolder')
        assert_equal true, list.include?(expected_base_path + '/sub-folder-two')
        assert_equal true, list.include?(expected_base_path + '/sub-folder-three')
        assert_equal false, list.include?(expected_base_path + '/sub-folder-one/subfolder/dummy-file')
    end
end
