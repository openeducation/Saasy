Given /^a project named "([^"]*)" exists under the "([^"]*)" account$/ do |project_name, account_name|
  account = Account.find_by_name!(account_name)
  Factory(:project, :account => account, :name => project_name)
end
