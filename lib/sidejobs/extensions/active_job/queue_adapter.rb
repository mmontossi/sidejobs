module Sidejobs
  module Extensions
    module ActiveJob
      module QueueAdapters
        class SidejobsAdapter
          class << self

            def enqueue(job)
              Sidejobs.queue.add(
                job.serialize,
                queue: job.queue_name,
                priority: calculate_priority(job.queue_name)
              )
            end

            def enqueue_at(job, timestamp)
              Sidejobs.queue.add(
                job.serialize,
                queue: job.queue_name,
                priority: calculate_priority(job.queue_name),
                schedule_at: Time.at(timestamp)
              )
            end

            private

            def calculate_priority(queue)
              case queue
              when 'mailers'
                80
              when 'high_priority'
                60
              when 'default'
                40
              when 'low_priority'
                20
              else
                0
              end
            end

          end
        end
      end
    end
  end
end
