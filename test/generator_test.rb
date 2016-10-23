require 'test_helper'
require 'rails/generators'
require 'generators/sidejobs/install_generator'

class GeneratorsTest < Rails::Generators::TestCase

  tests Sidejobs::Generators::InstallGenerator
  destination Rails.root.join('tmp')

  teardown do
    FileUtils.rm_rf destination_root
  end

  test 'file generation' do
    run_generator
    assert_file 'config/initializers/sidejobs.rb'
    assert_migration 'db/migrate/create_sidejobs.rb'
  end

end
