require 'test_helper'

class DaemonTest < ActiveSupport::TestCase

  test 'pid' do
    start
    assert daemon.running?

    old_pid = daemon.pid
    restart
    assert daemon.running?
    assert_not_equal old_pid, daemon.pid
    assert_not pid?(old_pid)

    pid = daemon.pid
    stop
    assert_nil daemon.pid
    assert_not pid?(pid)
  end

  test 'logger' do
    start
    ClearGuestUsersJob.perform_later
    SendNewslettersJob.perform_later
    UserMailer.invite('test@mail.com').deliver_later
    wait
    stop
    log = File.read(Rails.root.join('log/sidejobs.log'))

    assert_includes log, 'Performing SendNewslettersJob'
    assert_includes log, 'Performing ActionMailer::DeliveryJob'
    assert_includes log, 'Rendering text template'
    assert_includes log, 'Rendering user_mailer/invite.text.erb'
    assert_includes log, 'DELETE FROM "users"'
  end

  private

  delegate :daemon, to: Sidejobs

  %i(start restart).each do |name|
    define_method name do
      ActiveRecord::Base.connection.disconnect!
      fork do
        daemon.public_send name
      end
      ActiveRecord::Base.establish_connection
      wait
    end
  end

  def stop
    daemon.stop
    wait
  end

end
