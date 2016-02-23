require "logger"

class JobScheduler
    attr_accessor :logger
    attr_reader :queue

    def initialize
        @queue = Queue.new
    end

    def can_schedule?
        return @queue.empty?
    end

    def schedule(job_params)
        log(Logger::INFO, "Scheduling ctags job for #{job_params[:name]}")
    end

    def log(*arguments)
        @logger.log(*arguments) unless @logger.nil?
    end
end
