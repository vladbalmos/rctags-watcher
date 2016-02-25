require_relative "../lib/job_scheduler"
require "test/unit"

class TestJobScheduler < Test::Unit::TestCase

    def test_can_schedule_job
        scheduler = JobScheduler.new
        assert_equal true, scheduler.can_schedule?
    end

    def test_job_format
        scheduler = JobScheduler.new
        job_params = {
            :name => 'test_project',
            :change_path => '/tmp',
            :settings => {
                :project_settings => {
                    "path" => '/tmp',
                    "recursive" => true,
                    "pattern" => '*'
                },
                :ctags_settings => nil
            }
        }

        job = scheduler.make_job job_params

        assert_instance_of Hash, job
        assert_equal 'test_project_ctags_job', job[:name]
        assert_equal 'ctags -R /tmp -f /tmp/tags', job[:command]
    end

    def test_job_is_scheduled
        scheduler = JobScheduler.new
        job_params = {
            :name => 'test_project',
            :change_path => '/tmp',
            :settings => {
                :project_settings => {
                    "path" => '/tmp',
                    "recursive" => true,
                    "pattern" => '*'
                },
                :ctags_settings => nil
            }
        }

        scheduler.schedule job_params
        job = scheduler.queue.pop false
        assert_instance_of Hash, job
    end

end
