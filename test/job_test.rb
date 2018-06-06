require 'test_helper'

class JobTest < ActiveSupport::TestCase

  test 'started/finished' do
    job = Sidejobs::Job.new

    assert_not job.started?
    %w(executing failing complete failed).each do |state|
      job.state = state
      assert job.started?
    end

    %w(pending executing failing).each do |state|
      job.state = state
      assert_not job.finished?
    end
    %w(complete failed).each do |state|
      job.state = state
      assert job.finished?
    end
  end

  test 'duration' do
    job = Sidejobs::Job.new(
      started_at: Time.now,
      finished_at: (Time.now + 10.seconds)
    )
    assert_equal 10, job.duration
  end

  test 'retries' do
    ShareProductsJob.perform_later
    job = Sidejobs::Job.last

    last_schedule = nil
    (1..3).each do |executions|
      job.execute
      assert_equal 'Unavailable', job.exception
      seconds = (executions * 10)
      if executions < 3
        assert job.failing?
        assert_equal executions, job.executions
        assert_operator (job.scheduled_at - job.finished_at).round, :>=, seconds
        last_schedule = job.scheduled_at
      else
        assert job.failed?
        assert_equal 3, job.executions
        assert_equal last_schedule, job.scheduled_at
      end
    end
  end

  test 'queue' do
    2.times do
      SendNewslettersJob.perform_later
    end

    Sidejobs::Job.execute :newsletters
    assert_equal 1, Sidejobs::Job.complete.size
    assert_equal 1, Sidejobs::Job.pending.size

    Sidejobs::Job.execute :newsletters
    assert_equal 2, Sidejobs::Job.complete.size
    assert_equal 0, Sidejobs::Job.pending.size
  end

end
