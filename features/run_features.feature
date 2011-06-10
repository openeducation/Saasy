@disable-bundler @puts @announce
Feature: generate a saucy application and run rake

  Background:
    When I successfully run "bundle exec rails new testapp"
    And I cd to "testapp"
    And I copy the locked Gemfile from this project
    And I append to "Gemfile" with:
    """
    gem "clearance", :git => "git://github.com/thoughtbot/clearance.git"
    gem "cucumber-rails"
    gem "capybara"
    gem "factory_girl_rails"
    gem "dynamic_form"
    gem "database_cleaner"
    gem "formtastic"
    gem "rspec-rails"
    gem "bourne"
    gem "shoulda"
    gem "launchy"
    gem "timecop"
    gem "jquery-rails"
    """
    When I add the "saucy" gem from this project as a dependency
    And I successfully run "bundle install --local"
    And I successfully run "rails generate jquery:install --force"
    And I bootstrap the application for clearance
    And I bootstrap the application for saucy

  Scenario: generate a saucy application and run rake
    When I successfully run "rails generate saucy:install"
    And I successfully run "rails generate saucy:specs"
    And I successfully run "rails generate saucy:features"
    And I successfully run "rake db:migrate"
    And I run "rake"
    Then it should pass with:
    """
    passed
    """
    Then the output should not contain "failed"
    And the output should not contain "Could not find generator"

  Scenario: A new saucy app with custom views
    When I successfully run "rails generate saucy:install"
    And I successfully run "rails generate saucy:specs"
    And I successfully run "rails generate saucy:features"
    And I successfully run "rails generate saucy:views"
    And I successfully run "rake db:migrate"
    And I give a more detailed new account message
    And I run "rake"
    Then it should pass with:
    """
    passed
    """
    Then the output should not contain "failed"
    And the output should not contain "Could not find generator"

  Scenario: A new saucy app with custom layouts
    When I successfully run "rails generate saucy:install"
    And I successfully run "rails generate saucy:specs"
    And I successfully run "rails generate saucy:features"
    And I successfully run "rake db:migrate"
    And I add a custom layout to the accounts index
    And I run "rake"
    Then it should pass with:
    """
    passed
    """
    Then the output should not contain "failed"
    And the output should not contain "Could not find generator"

  Scenario: run specs
    When I successfully run "rails generate saucy:install"
    And I successfully run "rails generate saucy:specs"
    And I successfully run "rails generate saucy:features"
    And I successfully run "rake db:migrate"
    And I copy the specs for this project
    And I run "rake spec"
    Then it should pass with:
    """
    0 failures
    """
    Then at least one example should have run
