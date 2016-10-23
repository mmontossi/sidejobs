require 'test_helper'

class QueueTest < ActiveSupport::TestCase

  test 'enqueue' do
    UserMailer.invite('test@mail.com').deliver_later
    job = Sidejobs::Job.last
    assert_equal 'mailers', job.queue
    assert_equal 80, job.priority
    assert_nil job.scheduled_at

    ChargeSubscriptionsJob.perform_later
    job = Sidejobs::Job.last
    assert_equal 'high_priority', job.queue
    assert_equal 60, job.priority
    assert_nil job.scheduled_at

    SendNewslettersJob.perform_later
    job = Sidejobs::Job.last
    assert_equal 'default', job.queue
    assert_equal 40, job.priority
    assert_nil job.scheduled_at

    UpdateExchangesJob.perform_later
    job = Sidejobs::Job.last
    assert_equal 'low_priority', job.queue
    assert_equal 20, job.priority
    assert_nil job.scheduled_at

    ClearGuestUsersJob.perform_later
    job = Sidejobs::Job.last
    assert_equal 'other', job.queue
    assert_equal 0, job.priority
    assert_nil job.scheduled_at

    time = 10.hours.from_now

    UserMailer.invite('test@mail.com').deliver_later wait_until: time
    job = Sidejobs::Job.last
    assert_equal 'mailers', job.queue
    assert_equal 80, job.priority
    assert_equal time.to_i, job.scheduled_at.to_i

    ChargeSubscriptionsJob.set(wait_until: time).perform_later
    job = Sidejobs::Job.last
    assert_equal 'high_priority', job.queue
    assert_equal 60, job.priority
    assert_equal time.to_i, job.scheduled_at.to_i

    SendNewslettersJob.set(wait_until: time).perform_later
    job = Sidejobs::Job.last
    assert_equal 'default', job.queue
    assert_equal 40, job.priority
    assert_equal time.to_i, job.scheduled_at.to_i

    UpdateExchangesJob.set(wait_until: time).perform_later
    job = Sidejobs::Job.last
    assert_equal 'low_priority', job.queue
    assert_equal 20, job.priority
    assert_equal time.to_i, job.scheduled_at.to_i

    ClearGuestUsersJob.set(wait_until: time).perform_later
    job = Sidejobs::Job.last
    assert_equal 'other', job.queue
    assert_equal 0, job.priority
    assert_equal time.to_i, job.scheduled_at.to_i
  end

end
