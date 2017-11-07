module Sidejobs
  class Processor
    include Loggable

    def process
      Sidejobs.queue.fetch.each do |job|
        job.update state: 'processing', processed_at: Time.zone.now, attempts: job.attempts+1
        begin
          ActiveJob::Base.execute job.data
          job.update state: 'complete'
        rescue => exception
          job.update state: 'failing', error: exception.message
        end
      end
    end

  end
end
