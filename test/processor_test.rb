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
    assert job.complete?
    assert_nil job.error
    assert_equal 1, job.attempts
  end

  test 'batch' do
    (@batch_size + 4).times do
      UserMailer.invite('test@mail.com').deliver_later
    end
    @processor.process
    assert_equal @batch_size, Sidejobs::Job.complete.count
    assert_equal 0, Sidejobs::Job.processing.count
    assert_equal 4, Sidejobs::Job.pending.count

    Sidejobs::Job.last.update state: 'processing', processed_at: Time.now
    @processor.process
    assert_equal (@batch_size + 3), Sidejobs::Job.complete.count
    assert_equal 1, Sidejobs::Job.processing.count
    assert_equal 0, Sidejobs::Job.pending.count
  end

  test 'retries' do
    ShareProductsJob.perform_later
    (@max_attempts + 1).times do
      @processor.process
    end
    job = Sidejobs::Job.last
    assert job.failing?
    assert_equal 'Social network unavailable', job.error
    assert_equal @max_attempts, job.attempts
  end

end
