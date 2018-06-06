require 'test_helper'

class ProcessorTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'process' do
    Thread.new do
      processor.process
    end
    wait
    assert_equal 1, processor.pids[:mailers].size
    assert_equal 1, processor.pids[:newsletters].size
    assert_equal 2, processor.pids[:default].size
    processor.pids.values.flatten.each do |pid|
      assert pid?(pid)
    end

    2.times do
      SendNewslettersJob.perform_later
      wait
    end
    first = Sidejobs::Job.first
    last = Sidejobs::Job.last
    assert_operator (last.started_at - first.started_at), :>=, 15

    processor.stop
    wait
    processor.pids.values.flatten.each do |pid|
      assert_not pid?(pid)
    end
  end

  private

  def processor
    @processor ||= Sidejobs::Processor.new
  end

end
