require_relative "../lib/rctags-watcher/worker"
require "test/unit"
require "tmpdir"
require "fileutils"

class TestWorkerFunctional < Test::Unit::TestCase

    # Test that the worker thread exists after
    # a predetermined timeout passes if the work queue is empty
    def test_worker_stops_with_timeout
        work_queue = Queue.new

        w = Worker.new(work_queue)

        duration = time_block { w.stop }

        assert_equal true, duration > 1 and duration < 2
    end


    # Test that the worker thread exists just after finishing a running job
    def test_worker_stops_right_after_job_finishes
        work_queue = Queue.new

        w = Worker.new(work_queue)
        tmpdir = Dir.mktmpdir
        work_queue << {
            :test_command => '/bin/sleep 2 && touch tags',
            :scan_path => tmpdir,
            :tags_filename => 'tags'
        }

        sleep(1.0 / 5.0) # We need this in order to 
                         # allow for the thread to pop the queue and start running
        duration = time_block { w.stop }

        FileUtils.remove_entry tmpdir

        assert_equal true, (duration >= 1.5 and duration < 3), "Duration was #{duration.to_s}"
    end

    private

    def time_block
        start_time = Time.now.to_f
        yield
        end_time = Time.now.to_f

        return end_time - start_time
    end


end

