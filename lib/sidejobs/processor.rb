module Sidejobs
  class Processor
    include Loggable

    def process
      Sidejobs.queue.fetch.each do |job|
        job.update status: 'processing', processed_at: Time.now, attempts: job.attempts+1
        begin
          ActiveJob::Base.execute job.data
          job.update status: 'complete', completed_at: Time.now
        rescue => exception
          job.update status: 'failing', failed_at: Time.now, error: exception.message
        end
      end
    end

  end
end
