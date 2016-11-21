require 'test_helper'
require 'rails/generators'
require 'generators/sidejobs/install_generator'

class GeneratorsTest < Rails::Generators::TestCase
  destination Rails.root.join('tmp')

  teardown do
    FileUtils.rm_rf destination_root
  end

  test 'install' do
    self.class.tests Sidejobs::Generators::InstallGenerator
    run_generator
    assert_file 'config/initializers/sidejobs.rb'
    assert_migration 'db/migrate/create_sidejobs.rb'
  end

end
