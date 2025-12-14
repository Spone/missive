# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"
require "rails/generators/active_record"

module Missive
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def copy_missive_migrations
        migration_template "migrations/install_missive.rb.erb", "db/migrate/install_missive.rb"
      end

      private

      def migration_class_name
        if Rails::VERSION::MAJOR >= 5
          "ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]"
        else
          "ActiveRecord::Migration"
        end
      end
    end
  end
end
