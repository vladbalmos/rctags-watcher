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

require_relative "../lib/rctags-watcher/job_scheduler"
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

        assert_raises(RuntimeError.new('Project path does not exist: /unknown/dir')) { scheduler.make_job job_params }
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

    def test_ctags_languages_format_is_correct
        scheduler = JobScheduler.new

        tmp_dir = Dir.tmpdir

        job_params = {
            :name => 'test_project',
            :change_path => tmp_dir,
            :settings => {
                :project_settings => {
                    "path" => tmp_dir,
                    "recursive" => true,
                    "pattern" => '*',
                    "ctags_languages" => 'php,javascript,ruby,python,c'
                },
                :ctags_settings => nil
            }
        }

        job = scheduler.make_job job_params
        ctags_languages = job[:ctags_languages]

        assert_instance_of Array, ctags_languages
        assert_equal 5, ctags_languages.count
        assert_equal true, ctags_languages.include?('php')
        assert_equal true, ctags_languages.include?('javascript')
        assert_equal true, ctags_languages.include?('ruby')
        assert_equal true, ctags_languages.include?('python')
        assert_equal true, ctags_languages.include?('c')
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
