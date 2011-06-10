When /^I bootstrap the application for clearance$/ do
  steps %{
    When I remove the file "public/index.html"
    And I successfully run "rails generate cucumber:install"
    And I successfully run "rails generate clearance:install"
    And I successfully run "rails generate clearance:features"
    And I configure ActionMailer to use "www.example.com" as a host
    And I add flash messages to the layout
    And I add session links to the layout
    And I configure "clearance/sessions#new" as the root route
    And I disable Capybara Javascript emulation
  }
end

When /^I add flash messages to the layout$/ do
  flashes = %{
    <% flash.each do |key, value| -%>
      <%= value %>
    <% end -%>
  }

  replace_in_file "app/views/layouts/application.html.erb",
                  /(<body>)/,
                  "\\1\n#{flashes}"
end

When /^I add session links to the layout$/ do
  links = %{
    <% if signed_in? -%>
      <%= link_to 'Sign out', sign_out_path, :method => :delete %>
    <% else -%>
      <%= link_to 'Sign in', sign_in_path %>
    <% end -%>
  }

  replace_in_file "app/views/layouts/application.html.erb",
                  /(<body>)/,
                  "\\1\n#{links}"
end

When /^I configure "([^"]*)" as the root route$/ do |action|
  replace_in_file "config/routes.rb",
                  /(routes\.draw do)/,
                  "\\1\nroot :to => '#{action}'"
end
