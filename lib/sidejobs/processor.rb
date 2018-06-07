module Sidejobs
  class Processor

    def pids
      @pids ||= {}
    end

    def stop
      pids.values.flatten.each do |pid|
        Process.kill :TERM, pid
      end
    end

    def process
      Sidejobs.configuration.queues.each do |queue, concurrency|
        concurrency.times do
          logger.info "Spawing #{concurrency}"
          ActiveRecord::Base.connection.disconnect!
          (pids[queue] ||= []) << fork do
            stop = false
            trap :TERM do
              stop = true
            end
            until stop
              Job.execute queue
              sleep Sidejobs.configuration.sleep
            end
          end
          ActiveRecord::Base.establish_connection
        end
      end
      Process.waitall
    end

  end
end
