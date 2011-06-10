require 'generators/saucy/base'

module Saucy
  module Generators
    class FeaturesGenerator < Base

      desc <<DESC
Description:
    Copy saucy cucumber features files to your application.
DESC

      def copy_feature_files
        directory "features", "features/saucy"
        directory "step_definitions", "features/step_definitions/saucy"
        directory "support", "features/support/saucy"
        template "README", "features/saucy/README"
        template "README", "features/step_definitions/saucy/README"
        empty_directory "spec"
        empty_directory "spec/factories"
        template "factories.rb", "spec/factories/saucy_factories.rb"
      end

      def remove_conflicting_files
        remove_file "features/clearance/visitor_signs_up.feature"
        remove_file "spec/factories/clearance.rb"
        remove_file "test/factories/clearance.rb"
      end

      def create_paths
        paths = <<-PATHS
    when 'the list of accounts'
      accounts_path
    when 'the list of plans page'
      plans_path
    when /^the memberships page for the "([^"]+)" account$/
      account = Account.find_by_name!($1)
      account_memberships_path(account)
    when /^the projects page for the "([^"]+)" account$/
      account = Account.find_by_name!($1)
      account_projects_path(account)
    when /settings page for the "([^"]+)" account$/i
      account = Account.find_by_name!($1)
      edit_account_path(account)
    when /settings page$/
      edit_profile_path
    when /dashboard page$/
      accounts_path
    when /sign up page for the "([^"]+)" plan$/i
      plan = Plan.find_by_name!($1)
      new_plan_account_path(plan)
    when /^the billing page for the "([^"]+)" account$/
      account = Account.find_by_name!($1)
      account_billing_path(account)
    when /^the upgrade plan page for the "([^"]+)" account$/
      account = Account.find_by_name!($1)
      edit_account_plan_path(account)
    when /^the new project page for the newest account by "([^"]*)"$/
      user = User.find_by_email!($1)
      account = user.accounts.order("id desc").first
      new_account_project_path(account)
    when /^the "([^"]*)" project page$/
      project = Project.find_by_name!($1)
      account_project_path(project.account, project)
    when /^the new project page for the "([^"]+)" account$/
      account = Account.find_by_name!($1)
      new_account_project_path(account)


        PATHS

        replace_in_file "features/support/paths.rb",
                        "case page_name",
                        "case page_name\n#{paths}"
      end

      private

      def replace_in_file(relative_path, find, replace)
        path = File.join(destination_root, relative_path)
        contents = IO.read(path)
        unless contents.gsub!(find, replace)
          raise "#{find.inspect} not found in #{relative_path}"
        end
        File.open(path, "w") { |file| file.write(contents) }
      end

    end
  end
end


