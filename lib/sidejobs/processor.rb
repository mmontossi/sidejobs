module Sidejobs
  class Processor

    def process
      original_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = Sidejobs.logger
      Sidejobs.queue.fetch.each do |job|
        Sidejobs.logger.info "Processing #{job.data['job_class']} ##{job.id} attempt #{job.attempts+1} at #{job.queue}"
        job.update status: 'processing', processed_at: Time.now, attempts: job.attempts+1
        begin
          ActiveJob::Base.execute job.data
          job.update status: 'complete', completed_at: Time.now
          Sidejobs.logger.info 'Done'
        rescue => exception
          job.update status: 'failing', failed_at: Time.now, error: exception.message
          Sidejobs.logger.info "Error: #{exception.message}"
        end
      end
      ActiveRecord::Base.logger = original_logger
    end

  end
end
