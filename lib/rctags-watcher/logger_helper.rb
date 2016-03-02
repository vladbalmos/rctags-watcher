# %license%
module LoggerHelper
    attr_accessor :logger

    def log(*arguments)
        @logger.log(*arguments) unless @logger.nil?
    end
end
