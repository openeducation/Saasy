require 'generators/saucy/base'
require 'rails/generators/active_record/migration'

module Saucy
  module Generators
    class InstallGenerator < Base
      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      desc <<DESC
Description:
    Copy saucy files to your application.
DESC

      def generate_migration
        migration_template "create_saucy_tables.rb", "db/migrate/create_saucy_tables.rb"
      end

      def create_models
        directory "models", "app/models"
      end

      def create_controllers
        directory "controllers", "app/controllers"
      end

      def update_user_model
        insert_into_file "app/models/user.rb",
                         "\ninclude Saucy::User",
                         :after => "include Clearance::User"
      end

      def add_account_authorization
        insert_into_file "app/controllers/application_controller.rb",
                         "\ninclude Saucy::AccountAuthorization",
                         :after => "include Clearance::Authentication"
      end
    end
  end
end
