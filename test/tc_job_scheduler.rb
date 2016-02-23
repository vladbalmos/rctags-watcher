require_relative "../lib/job_scheduler"
require "test/unit"

class TestJobScheduler < Test::Unit::TestCase

    def test_can_schedule_job
        scheduler = JobScheduler.new
        assert_equal true, scheduler.can_schedule?
    end

    def test_job_is_scheduled
        scheduler = JobScheduler.new
        job_params = {
            :name => 'test_project',
            :change_path => '/tmp',
            :settings => {}
        }

        scheduler.schedule job_params
        job = scheduler.queue.pop false
        assert_instance_of Hash, job
        # to be continued
    end

end
