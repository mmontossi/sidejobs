require 'sidejobs/extensions/active_job/queue_adapter'
require 'sidejobs/configuration'
require 'sidejobs/loggable'
require 'sidejobs/daemon'
require 'sidejobs/job'
require 'sidejobs/processor'
require 'sidejobs/queue'
require 'sidejobs/railtie'
require 'sidejobs/version'

module Sidejobs
  class << self

    def daemon
      @daemon ||= Daemon.new
    end

    def queue
      @queue ||= Queue.new
    end

    def logger
      @logger ||= ActiveSupport::Logger.new(Rails.root.join('log/sidejobs.log'))
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

  end
end
