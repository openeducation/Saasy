Given /^I (?:am signed in|sign in) as an admin of the "([^"]+)" project$/ do |project_name|
  project = Project.find_by_name!(project_name)
  user    = Factory(:user)
  membership = Factory(:membership, :user    => user,
                                                    :account => project.account,
                                                    :admin   => true)
  Factory(:permission, :membership => membership,
                               :project            => project)
  When %{I sign in as "#{user.email}"}
end

Given /^I am signed in as "([^"]*)" under the "([^"]*)" account$/ do |email, account_name|
  account = Factory(:account, :name => account_name)
  user    = Factory(:user, :email => email)
  membership = Factory(:membership, :user => user, :account => account)
  When %{I sign in as "#{user.email}"}
end

Given /^I am signed in as an admin of the "([^"]*)" account$/ do |account_name|
  account = Account.find_by_name!(account_name)
  user    = Factory(:user)
  Factory(:membership, :user    => user,
                               :account => account,
                               :admin   => true)
  When %{I sign in as "#{user.email}"}
end

When /^I sign in as "([^"\/]*)"$/ do |email|
  user = User.find_by_email!(email)
  user.update_attributes!(:password => 'test')
  When %{I sign in as "#{email}/test"}
end

Given /^I am signed in$/ do
  user = Factory(:user)
  When %{I sign in as "#{user.email}"}
end
