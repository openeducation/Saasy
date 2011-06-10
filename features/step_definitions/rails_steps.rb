When /^I configure ActionMailer to use "([^"]+)" as a host$/ do |host|
  mailer_config = "config.action_mailer.default_url_options = { :host => '#{host}' }"
  replace_in_file "config/application.rb",
                  /(class .* < Rails::Application)/,
                  "\\1\n#{mailer_config}"
end

When /^I add the "([^"]*)" gem from this project as a dependency$/ do |gem_name|
  append_to_file('Gemfile', %{\ngem "#{gem_name}", :path => "#{PROJECT_ROOT}"})
end

When /^I disable Capybara Javascript emulation$/ do
  replace_in_file "features/support/env.rb",
                  %{require 'cucumber/rails/capybara_javascript_emulation'},
                  "# Disabled"
end

When /^I give a more detailed new account message$/ do
  account_message = "Please sign up now."
  replace_in_file 'app/views/accounts/new.html.erb',
    %r{(</h2>)},
    "\\1\n#{account_message}"

  scenario = <<-HERE
  Feature: The new account page should have a desperate message
    Scenario: New account message
      Given a plan exists with a name of "Free"
      When I go to the sign up page for the "Free" plan
      Then I should see "Please sign up now"
  HERE
  create_file('features/new_account_message.feature', scenario)
end

When /^I add a custom layout to the accounts index$/ do
  in_current_dir do
    FileUtils.cp("app/views/layouts/application.html.erb",
                 "app/views/layouts/custom.html.erb")
  end
  replace_in_file 'app/views/layouts/custom.html.erb',
                  %r{(<body>)},
                  "\\1\nCustom Layout Content"
  layout_config = "config.saucy.layouts.accounts.index = 'custom'"
  replace_in_file "config/application.rb",
                  /(class .* < Rails::Application)/,
                  "\\1\n#{layout_config}"

  create_file('features/custom_accounts_index_layout.feature', <<-SCENARIO)
  Feature: The accounts index should have a custom layout
    Scenario: Custom layout
      Given I am signed up as "email@person.com/password"
      And the following projects exist:
        | name       | account   |
        | ClothesPin | name: One |
        | Talkr      | name: Two |
        | Fabio      | name: One |
      And "email@person.com" is a member of the "ClothesPin" project
      And "email@person.com" is a member of the "Talkr" project
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      And I go to the dashboard page
      Then I should see "Custom Layout Content"
  SCENARIO
end

When /^I copy the specs for this project$/ do
  in_current_dir do
    FileUtils.cp_r(File.join(PROJECT_ROOT, 'spec'), '.')
  end
end

Then /^at least one example should have run$/ do
  Then %{the output should match /[1-9]0* examples/}
end
