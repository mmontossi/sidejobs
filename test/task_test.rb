require 'test_helper'
require 'rake'
load File.expand_path('../../lib/tasks/sidejobs.rake', __FILE__)
Rake::Task.define_task :environment

class TaskTest < ActiveSupport::TestCase

  test 'start' do
    Sidejobs.daemon.expects(:start).once
    Rake::Task['sidejobs:start'].invoke
  end

  test 'stop' do
    Sidejobs.daemon.expects(:stop).once
    Rake::Task['sidejobs:stop'].invoke
  end

  test 'restart' do
    Sidejobs.daemon.expects(:restart).once
    Rake::Task['sidejobs:restart'].invoke
  end

end
