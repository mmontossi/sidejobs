module Sidejobs
  class Configuration

    attr_accessor :executions, :sleep

    def queues
      @queues ||= {}
    end

    def queue(name, concurrency)
      queues[name] = concurrency
    end

  end
end
