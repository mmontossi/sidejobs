require 'sidejobs/extensions/active_job/queue_adapter'
require 'sidejobs/configuration'
require 'sidejobs/daemon'
require 'sidejobs/engine'
require 'sidejobs/processor'
require 'sidejobs/railtie'
require 'sidejobs/version'

module Sidejobs
  class << self

    def daemon
      @daemon ||= Daemon.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

  end
end
