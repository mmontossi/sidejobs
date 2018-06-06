require 'test_helper'

class AdapterTest < ActiveSupport::TestCase

  test 'enqueue' do
    UserMailer.invite('test@mail.com').deliver_later
    job = Sidejobs::Job.where(queue: 'mailers').last
    assert_nil job.scheduled_at

    SendNewslettersJob.perform_later
    job = Sidejobs::Job.where(queue: 'newsletters').last
    assert_nil job.scheduled_at

    ClearGuestUsersJob.perform_later
    job = Sidejobs::Job.where(queue: 'default').last
    assert_nil job.scheduled_at

    time = 10.hours.from_now

    UserMailer.invite('test@mail.com').deliver_later wait_until: time
    job = Sidejobs::Job.where(queue: 'mailers').last
    assert_equal time.to_i, job.scheduled_at.to_i

    SendNewslettersJob.set(wait_until: time).perform_later
    job = Sidejobs::Job.where(queue: 'newsletters').last
    assert_equal time.to_i, job.scheduled_at.to_i

    ClearGuestUsersJob.set(wait_until: time).perform_later
    job = Sidejobs::Job.where(queue: 'default').last
    assert_equal time.to_i, job.scheduled_at.to_i
  end

end
