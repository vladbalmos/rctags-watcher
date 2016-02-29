require "test/unit"
require "open3"
require "fileutils"

class TestFunctional < Test::Unit::TestCase

    # So it's like this:
    # Run the program 
    # Append a php function a file in the project
    # Wait a bit
    # Assert that the tags file exists and that it contains our function
    def test
        config_file = ENV['TEST_CONFIG_FILE']
        binary = "bin/rctags-watcher.rb -c #{config_file}"
        puts $\, binary
        stdin, stdout, stderr, wait_thr = Open3.popen3 binary
        pid = wait_thr.pid

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
        puts $\, "Modify source file command exit status: #{$?.to_i}"

        sleep 5

        Process.kill("INT", pid)

        output_stream = stdout.read
        error_stream  = stderr.read

        puts $\, "Output stream: (#{output_stream.length})", "-------------------", output_stream
        puts $\, "Error stream: (#{error_stream.length})", "-------------------", error_stream

        stdin.close
        stdout.close
        stderr.close

        exit_status = wait_thr.value
        assert_equal 0, exit_status.to_i

        assert_equal 0, error_stream.length

        expected_tags_file = ENV['TEST_TAGS_FILE']
        assert_equal true, File.file?(expected_tags_file)

        assert_equal true, File.size(expected_tags_file) > 0
        assert_equal true, File.read(expected_tags_file).include?('rctags_watcher_test_fn')

    end

end
