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

require_relative "logger_helper"
require "logger"

class JobScheduler

    include LoggerHelper
    attr_reader :queue
    attr_accessor :worker

    def initialize
        @queue = Queue.new
        @worker = nil
    end

    def can_schedule?
        if !@worker.nil? && @worker.job_running?
            return false
        end

        return @queue.empty?
    end

    def schedule(job_params)
        log Logger::INFO, "Scheduling ctags job for #{job_params[:name]}"

        begin
            job = make_job job_params
        rescue RuntimeError => e
            log Logger::ERROR, e.message
            return false
        end
        @queue << job
        return true
    end

    def make_job(job_params)
        ctags_settings = job_params[:settings][:ctags_settings]
        project_settings = job_params[:settings][:project_settings]

        if !ctags_settings.nil? && !ctags_settings[:bin].nil?
            ctags_binary = ctags_settings[:bin]
        else
            ctags_binary = 'ctags'
        end

        scan_path = File.expand_path project_settings["path"]

        raise "Project path does not exist: #{scan_path}" unless File.directory? scan_path

        tags_filename = project_settings['tags_filename'].nil? ? 'tags' : project_settings["tags_filename"]
        ctags_languages = prepare_ctags_languages project_settings["ctags_languages"]

        job = {
            :name => job_params[:name] + '_ctags_job',
            :ctags_binary => ctags_binary,
            :scan_path => scan_path,
            :tags_filename => tags_filename,
            :recursive => project_settings['recursive'],
            :ctags_languages => ctags_languages
        }
        return job
    end

    private

    def prepare_ctags_languages(languages)
        unless languages
            return
        end
        lang_array = languages.split(',').compact
        lang_array.collect! { |item| item.strip }

        return lang_array
    end

end
