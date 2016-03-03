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

