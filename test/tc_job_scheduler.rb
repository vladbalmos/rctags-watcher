require_relative "../lib/job_scheduler"
require "tmpdir"
require "test/unit"

class TestJobScheduler < Test::Unit::TestCase

    def test_can_schedule_job
        scheduler = JobScheduler.new
        assert_equal true, scheduler.can_schedule?
    end

    def test_make_job_raises_exception_when_project_path_is_invalid
        scheduler = JobScheduler.new

        job_params = {
            :name => 'test_project',
            :change_path => '/unknown/dir',
            :settings => {
                :project_settings => {
                    "path" => '/unknown/dir',
                    "recursive" => true,
                    "pattern" => '*'
                },
                :ctags_settings => nil
            }
        }

        assert_raise_with_message(RuntimeError, 'Project path does not exist: /unknown/dir') {
            scheduler.make_job job_params
        }
    end

    def test_job_format_is_correct
        scheduler = JobScheduler.new

        tmp_dir = Dir.tmpdir

        job_params = {
            :name => 'test_project',
            :change_path => tmp_dir,
            :settings => {
                :project_settings => {
                    "path" => tmp_dir,
                    "recursive" => true,
                    "pattern" => '*'
                },
                :ctags_settings => nil
            }
        }

        job = scheduler.make_job job_params

        assert_instance_of Hash, job
        assert_equal 'test_project_ctags_job', job[:name]
        assert_equal 'ctags', job[:ctags_binary]
        assert_equal true, job[:recursive]
        assert_equal 'tags', job[:tags_filename]
        assert_equal tmp_dir, job[:scan_path]
    end

    def test_job_is_scheduled
        tmp_dir = Dir.tmpdir

        scheduler = JobScheduler.new

        job_params = {
            :name => 'test_project',
            :change_path => tmp_dir,
            :settings => {
                :project_settings => {
                    "path" => tmp_dir,
                    "recursive" => true,
                    "pattern" => '*'
                },
                :ctags_settings => nil
            }
        }

        is_scheduled = scheduler.schedule job_params
        assert_equal true, is_scheduled
        job = scheduler.queue.pop false
        assert_instance_of Hash, job
    end

end
