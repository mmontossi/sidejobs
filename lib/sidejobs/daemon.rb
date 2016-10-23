module Sidejobs
  class Daemon

    def initialize
      @stopping = false
    end

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
        daemonize
        write_pid
        trap_signals
        process
      end
    end

    def stop
      if running?
        Process.kill :TERM, pid
        delete_pid
      end
    end

    def restart
      if running?
        stop
        start
      else
        start
      end
    end

    def pid
      File.read(pid_path).to_i rescue nil
    end

    def stopping?
      @stopping == true
    end

    private

    def daemonize
      exit if fork
      Process.setsid
      exit if fork
      Dir.chdir '/'
      File.umask 0000
      $stdout.reopen log_path, 'a'
      $stderr.reopen $stdout
      $stdout.sync = true
    end

    def trap_signals
      trap :TERM do
        @stopping = true
      end
    end

    def delete_pid
      File.unlink pid_path
    end

    def write_pid
      FileUtils.mkdir_p pid_path.dirname
      File.write pid_path, Process.pid
    end

    def log_path
      Rails.root.join 'log/sidejobs.log'
    end

    def pid_path
      Rails.root.join 'tmp/pids/sidejobs.pid'
    end

    def processor
      @processor ||= Processor.new
    end

    def process
      Sidejobs.logger.info 'Starting'
      until stopping? do
        processor.process
        sleep Sidejobs.configuration.sleep_delay
      end
      Sidejobs.logger.info 'Stopping'
    end

  end
end
