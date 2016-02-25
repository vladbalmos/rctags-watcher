require_relative "logger_helper"
require "logger"
require "thread"

class Worker < Thread

    include LoggerHelper

    def initialize(work_queue)
        super(work_queue, &method(:work))
    end

    def work(work_queue)
        return if work_queue.nil?
        while job = work_queue.pop
            log(Logger::DEBUG, "Running command #{job[:command]}")
            result = `#{job[:command]}`

            if result.nil?
                exit_status = $?.exitstatus.to_s
                log(Logger::ERROR, "Unable to execute job command. Exit status: #{exit_status}")
            elsif result == false
                exit_status = $?.exitstatus.to_s
                log(Logger::ERROR, "Job command was unsuccessful. Exit status: #{exit_status}")
            else
                log(Logger::INFO, "Job command executed successfully.")
            end
        end
    end

    def stop
        join 1
    end
end
