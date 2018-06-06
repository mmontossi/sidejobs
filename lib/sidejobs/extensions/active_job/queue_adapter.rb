module Sidejobs
  module Extensions
    module ActiveJob
      module QueueAdapters
        class SidejobsAdapter

          def enqueue(*args)
            Job.enqueue *args
          end

          def enqueue_at(*args)
            Job.enqueue *args
          end

        end
      end
    end
  end
end
