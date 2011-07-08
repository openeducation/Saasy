Saasy
=====
Please note: This project was started by [ThoughtBot](https://github.com/ThoughtBot). It was known by them as "Saucy". This project wasn't listed on their GitHub profile, thus I have taken it under wing. 

Sassy is a Rails engine for monthly subscription-style SaaS apps.

Example scenarios covered by Saasy:

* I sign up for "Free" plan under new account "thoughtbot"
* I am an admin and can be reached at "dan@example.com"
* I create a project "Hoptoad"
* I upgrade to the "Basic" plan and my credit card is charged
* I now have permissions to add users and projects to the "thoughtbot" account
* I invite "joe@example.com" to "Hoptoad"
* I create a project "Trajectory"
* I invite "mike@example.com" to "Trajectory"

Installation
------------

In your Gemfile:

    gem "saasy"

After you bundle, run the generator:

    rails generate saucy:install

You will want to include the `ensure_active_account` `before_filter` in any controller actions that you want to protect if the user is using an past due paid account.

You will want to customize the from email addresses.

Support email address for your application:

    Saucy::Configuration.support_email_address = "support@example.com"

Personalizable emails such as trial expiration notice and activation encouragement are sent from a product manager personal address:

    Saucy::Configuration.manager_email_address = "manager@example.com"

If you have an account with Braintree with multiple merchant accounts you'll want to configure the merchant account for this application:

Saucy::Configuration.merchant_account_id = 'your merchant account id'

In addition, there are a number of strings such as application name, support url, automated emails, etc. that are provided and customized with i18n translations.  You can customize these in your app, and you can see what they are by looking at config/locales/en.yml in saucy.

There is a `saucy:daily` rake task which should be run on a regular basis to send receipts and payment processing problem emails.

Saucy accounts become "activated" once an initial setup step is complete. This could be creating the first bug for a bug tracker, or setting up a client gem for a server API. Once the application detects that the account is activate, it should set "activated" to true on the account. This will prevent followup emails being sent to users that have already set up their accounts.

Development environment
-----------------------

Plans need to exist for users to sign up for. In db/seeds.rb:

    %w(free expensive mega-expensive).each do |plan_name|
      Plan.find_or_create_by_name(plan_name)
    end

Then run: rake db:seed

Test environment
----------------

Generate the Braintree Fake for your specs:

    rails generate saucy:specs

Generate feature coverage:

    rails generate saucy:features

To use seed data in your Cucumber, add this to features/support/seed.rb:

    require Rails.root.join('db','seeds')

Customization
-------------

By default Saucy uses and provides a `saucy.html.erb` layout. To change the 
layout for a controller inside of saucy, add a line like this to your 
config/application.rb:

    config.saucy.layouts.accounts.index = "custom"

In addition to just the normal yield, your layout should yield the following 
items in order to get everything from saucy views:

* :header
* :subnav

To extend the ProjectsController:

    class ProjectsController < ApplicationController
      include Saucy::ProjectsController

      def edit
        super
        @deleters = @project.deleters
      end
    end

To define additional limit meters, or override existing limit meters, create the
partials:

    app/views/limits/_#{limitname}_meter.html.erb

You can override all the views by generating them into your app and customizing them there:

    rails g saucy:views

## Gotchas

Make sure you don't do this in ApplicationController:

    before_filter :authenticate

Saucy's internal controllers don't skip any before filters.

