require File.expand_path('../../test/dummy/config/environment.rb', __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../test/dummy/db/migrate', __FILE__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'

# Filter out Minitest backtrace while allowing backtrace from other libraries to be shown
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = (ActiveSupport::TestCase.fixture_path + '/files')
  ActiveSupport::TestCase.fixtures :all
end

class ActiveSupport::TestCase

  teardown do
    Sidejobs::Job.destroy_all
  end

  private

  def pid?(pid)
    begin
      Process.kill 0, pid
      true
    rescue Errno::ESRCH
      false
    end
  end

  def wait
    sleep 20
  end

end
