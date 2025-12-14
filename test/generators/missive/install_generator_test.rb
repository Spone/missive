require "test_helper"
require "generators/missive/install_generator"

module Missive
  class InstallGeneratorTest < Rails::Generators::TestCase
    tests Missive::Generators::InstallGenerator
    destination File.expand_path("../../../../tmp", __FILE__)
    setup do
      prepare_destination
      run_generator
    end

    test "creates migration file" do
      assert_migration "db/migrate/install_missive.rb", /class InstallMissive/
    end

    test "injects the correct Rails version in migration file" do
      assert_migration "db/migrate/install_missive.rb", /< ActiveRecord::Migration\[#{ActiveRecord::Migration.current_version}\]/
    end
  end
end
