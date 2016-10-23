require 'test_helper'

class ProcessorTest < ActiveSupport::TestCase

  setup do
    @processor = Sidejobs::Processor.new
    @batch_size = Sidejobs.configuration.batch_size
    @max_attempts = Sidejobs.configuration.max_attempts
  end

  test 'process' do
    UserMailer.invite('test@mail.com').deliver_later
    @processor.process
    job = Sidejobs::Job.last
    assert_equal 'complete', job.status
    assert_nil job.error
    assert_equal 1, job.attempts
    assert_operator job.completed_at, :>, job.processed_at
  end

  test 'batch' do
    (@batch_size + 4).times do
      UserMailer.invite('test@mail.com').deliver_later
    end
    @processor.process
    assert_equal @batch_size, Sidejobs::Job.where(status: 'complete').count
    assert_equal 0, Sidejobs::Job.where(status: 'processing').count
    assert_equal 4, Sidejobs::Job.where(status: 'pending').count

    Sidejobs::Job.last.update status: 'processing'
    @processor.process
    assert_equal (@batch_size + 3), Sidejobs::Job.where(status: 'complete').count
    assert_equal 1, Sidejobs::Job.where(status: 'processing').count
    assert_equal 0, Sidejobs::Job.where(status: 'pending').count
  end

  test 'retries' do
    ShareProductsJob.perform_later
    (@max_attempts + 1).times do
      @processor.process
    end
    job = Sidejobs::Job.last
    assert_equal 'failing', job.status
    assert_equal 'Social network unavailable', job.error
    assert_equal @max_attempts, job.attempts
    assert_operator job.failed_at, :>, job.processed_at
  end

end
