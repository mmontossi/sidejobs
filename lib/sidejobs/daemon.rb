module Sidejobs
  class Daemon
    include Loggable

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
      if running?
        Process.kill :HUP, pid
      else
        start
      end
    end

    def pid
      File.read(pid_path).to_i rescue nil
    end

    private

    def spawn
      daemonize
      write_pid
      trap_signals
      process
    end

    def daemonize
      Process.daemon
    end

    def trap_signals
      trap :TERM do
        @signal = :stop
      end
      trap :HUP do
        @signal = :restart
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

    def handle_signal
      case @signal
      when :stop
        delete_pid
      when :restart
        @signal = nil
        spawn
      end
    end

    def signal_received?
      @signal.present?
    end

    def process
      logger.info "Started #{pid} at #{Time.zone.now}"
      until signal_received? do
        processor.process
        sleep Sidejobs.configuration.sleep_delay
      end
      logger.info "Stopped #{pid} at #{Time.zone.now}"
      handle_signal
    end

  end
end
