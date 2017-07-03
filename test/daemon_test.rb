require 'test_helper'

class DaemonTest < ActiveSupport::TestCase

  setup do
    @daemon = Sidejobs.daemon
    @pid_path = Rails.root.join('tmp/sidejobs.pid')
  end

  teardown do
    FileUtils.rm_rf @pid_path
  end

  test 'process' do
    fork_process do
      @daemon.start
    end
    assert @daemon.pid
    assert File.exist?(@pid_path)
    assert Process.pid != @daemon.pid
    assert process_exists?(@daemon.pid)

    pid = @daemon.pid
    fork_process do
      @daemon.restart
    end
    wait_process pid
    assert @daemon.pid
    assert File.exist?(@pid_path)
    assert Process.pid != @daemon.pid
    assert pid != @daemon.pid
    assert process_exists?(@daemon.pid)
    assert_not process_exists?(pid)

    pid = @daemon.pid
    @daemon.stop
    wait_process pid
    assert_nil @daemon.pid
    assert_not File.exist?(@pid_path)
    assert_not process_exists?(pid)
  end

  test 'pulling' do
    @daemon.stubs(:daemonize)
    @daemon.stubs(:signal_received?).returns(false, true)
    processor = mock
    processor.expects(:process).once
    @daemon.stubs(:processor).returns(processor)
    @daemon.expects(:sleep).with(Sidejobs.configuration.sleep_delay).once
    @daemon.start
  end

  private

  def process_exists?(pid)
    begin
      Process.kill 0, pid
      true
    rescue Errno::ESRCH
      false
    end
  end

  def wait_process(pid)
    Timeout::timeout(60 * 5) do
      sleep 5 while process_exists?(pid)
    end
  end

  def fork_process(&block)
    fork &block
    ActiveRecord::Base.connection.reconnect!
  end

end
