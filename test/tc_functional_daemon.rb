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

require "test/unit"
require "open3"
require "fileutils"

class TestFunctionalDaemon < Test::Unit::TestCase

    # So it's like this:
    # Run the program in daemon mode
    # Append a php function a file in the project
    # Wait a bit
    # Send the stop command to daemon
    # Assert that the tags file exists and that it contains our function
    # Make sure the communication with the daemon was made as expected
    def test_main
        # Start the daemon
        config_file = ENV['TEST_CONFIG_FILE']
        binary = "bin/rctags-watcher.rb -c #{config_file} -d"
        puts $\, binary
        stdin, stdout, stderr, wait_thr = Open3.popen3 binary

        # Wait a bit for the initialization
        sleep 1

        # Modify the source code a bit
        php_file = ENV['TEST_PHP_FILE']
        test_php_function = <<-EOT

        function rctags_watcher_test_fn()
        {
            echo 'hello from the rctags_functional_test';
        }
        EOT
        File.open(php_file, 'a') { |f| f.puts test_php_function }

        # Kill the daemon
        sleep 5
        system("bin/rctags-watcher.rb stop")

        # Show us some output
        output_stream = stdout.read
        error_stream  = stderr.read
        puts $\, "Output stream: (#{output_stream.length})", "-------------------", output_stream
        puts $\, "Error stream: (#{error_stream.length})", "-------------------", error_stream

        # Cleanup
        stdin.close
        stdout.close
        stderr.close

        # Did it have a clean exit?
        exit_status = wait_thr.value
        assert_equal 0, exit_status.to_i
        assert_equal 0, error_stream.length

        # Do we have a tags file?
        expected_tags_file = ENV['TEST_TAGS_FILE']
        assert_equal true, File.file?(expected_tags_file)

        # Does the tags file includes our dummy function?
        assert_equal true, File.size(expected_tags_file) > 0
        assert_equal true, File.read(expected_tags_file).include?('rctags_watcher_test_fn')

        # Did the communication with the daemon work as expected?
        assert_equal false, output_stream.index("Executing command get_pid").nil?
        assert_equal false, output_stream.index("Sending response to client:").nil?
    end

end
