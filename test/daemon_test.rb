require 'test_helper'

class DaemonTest < ActiveSupport::TestCase

  setup do
    @daemon = Sidejobs.daemon
    @pid_path = Rails.root.join('tmp/pids/sidejobs.pid')
  end

  teardown do
    FileUtils.rm_rf @pid_path
  end

  test 'process' do
    fork do
      @daemon.start
    end
    reconnect
    sleep 4
    assert @daemon.pid
    assert File.exist?(@pid_path)
    assert Process.pid != @daemon.pid
    assert process_exist?(@daemon.pid)

    pid = @daemon.pid
    fork do
      @daemon.restart
    end
    reconnect
    sleep 4
    assert @daemon.pid
    assert File.exist?(@pid_path)
    assert Process.pid != @daemon.pid
    assert process_exist?(@daemon.pid)
    sleep 8
    assert_not process_exist?(pid)

    pid = @daemon.pid
    @daemon.stop
    assert_nil @daemon.pid
    assert_not File.exist?(@pid_path)
    sleep 8
    assert_not process_exist?(pid)
  end

  test 'pulling' do
    @daemon.stubs(:daemonize)
    @daemon.stubs(:stopping?).returns(false, true)
    processor = mock
    processor.expects(:process).once
    @daemon.stubs(:processor).returns(processor)
    @daemon.expects(:sleep).with(Sidejobs.configuration.sleep_delay).once
    @daemon.start
  end

  private

  def process_exist?(pid)
    begin
      Process.kill 0, pid
      true
    rescue Errno::ESRCH
      false
    end
  end

  def reconnect
    ActiveRecord::Base.connection.reconnect!
  end

end
