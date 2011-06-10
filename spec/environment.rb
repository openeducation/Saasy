PROJECT_ROOT = File.expand_path("../..", __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, "lib")

require 'rails/all'
require 'saucy'
require 'clearance'
require 'factory_girl'
require 'bourne'

FileUtils.rm_f(File.join(PROJECT_ROOT, 'tmp', 'test.sqlite3'))

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  include Saucy::AccountAuthorization
end

class ProjectsController < ApplicationController
  include Saucy::ProjectsController
end

class User < ActiveRecord::Base
  include Clearance::User
  include Saucy::User
end

class Plan < ActiveRecord::Base
  include Saucy::Plan
end

module Testapp
  class Application < Rails::Application
    config.action_mailer.default_url_options = { :host => 'localhost' }
    config.encoding = "utf-8"
    config.paths.config.database = "spec/scaffold/config/database.yml"
    config.paths.app.models << "lib/generators/saucy/install/templates/models"
    config.paths.config.routes << "spec/scaffold/config/routes.rb"
    config.paths.app.views << "spec/scaffold/views"
    config.paths.log = "tmp/log"
    config.cache_classes = true
    config.whiny_nils = true
    config.consider_all_requests_local = true
    config.action_controller.perform_caching = false
    config.action_dispatch.show_exceptions = false
    config.action_controller.allow_forgery_protection = false
    config.action_mailer.delivery_method = :test
    config.active_support.deprecation = :stderr
  end
end

Testapp::Application.initialize!

require "lib/generators/saucy/features/templates/factories"
require "lib/generators/saucy/install/templates/create_saucy_tables"

class ClearanceCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string   :email
      t.string   :encrypted_password, :limit => 128
      t.string   :salt,               :limit => 128
      t.string   :confirmation_token, :limit => 128
      t.string   :remember_token,     :limit => 128
      t.boolean  :email_confirmed, :default => false, :null => false
      t.timestamps
    end

    add_index :users, :email
    add_index :users, :remember_token
  end
end

class ClearanceMailer
  def self.change_password(user)
    new
  end

  def self.confirmation(user)
    new
  end

  def self.deliver_change_password(user)
  end

  def self.deliver_confirmation(user)
  end

  def deliver
  end
end

Clearance.configure do |config|
end

ClearanceCreateUsers.suppress_messages { ClearanceCreateUsers.migrate(:up) }
CreateSaucyTables.suppress_messages { CreateSaucyTables.migrate(:up) }
