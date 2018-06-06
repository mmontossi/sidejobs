module Sidejobs
  class Daemon

    def running?
      if pid
        begin
          Process.kill 0, pid
          true
        rescue Errno::ESRCH
          false
        end
      else
        false
      end
    end

    def start
      unless running?
        spawn
      end
    end

    def stop
      if running?
        Process.kill :TERM, pid
      end
    end

    def restart
      stop
      spawn
    end

    def pid
      File.read(pid_path).to_i rescue nil
    end

    private

    def spawn
      daemonize
      write_pid
      trap_signals
      redirect_logs
      process
    end

    def daemonize
      Process.daemon
    end

    def logger
      @logger ||= ActiveSupport::Logger.new(Rails.root.join('log/sidejobs.log'))
    end

    def redirect_logs
      [ActionMailer, ActionController, ActionView, ActiveJob, ActiveRecord].each do |mod|
        mod.const_get('Base').logger = logger
      end
    end

    def trap_signals
      trap :TERM do
        processor.stop
      end
    end

    def delete_pid
      FileUtils.rm_rf pid_path
    end

    def write_pid
      FileUtils.mkdir_p pid_path.dirname
      File.write pid_path, Process.pid
    end

    def pid_path
      Rails.root.join 'tmp/sidejobs.pid'
    end

    def processor
      @processor ||= Processor.new
    end

    def process
      logger.info "Started #{pid} at #{Time.now}"
      processor.process
      logger.info "Stopped #{pid} at #{Time.now}"
      # Is possible to have old and new instance active at the same time for a moment
      if Process.pid == pid
        delete_pid
      end
    end

  end
end
