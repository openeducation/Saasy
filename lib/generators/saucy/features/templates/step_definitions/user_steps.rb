Given /^"([^"]*)" is a member of the "([^"]*)" project$/ do |email, project_name|
  user = User.find_by_email!(email)
  project = Project.find_by_name!(project_name)
  membership = Membership.find_by_user_id_and_account_id(user, project.account) ||
               Factory(:membership, :user => user, :account => project.account)
  Factory(:permission, :membership => membership, :project => project)
end

Given /^"([^"]*)" is an admin of the "([^"]*)" project$/ do |email, project_name|
  user = User.find_by_email!(email)
  project = Project.find_by_name!(project_name)
  if membership = Membership.find_by_user_id_and_account_id(user, project.account)
    membership.update_attribute(:admin, true)
  else
    membership = Factory(:membership, :user    => user,
                                      :account => project.account,
                                      :admin   => true)
  end
  Factory(:permission, :membership => membership, :project => project)
end

Given /^"([^"]*)" is a member of the "([^"]*)" account/ do |email, account_name|
  user = User.find_by_email!(email)
  account = Account.find_by_name!(account_name)
  Factory(:membership, :user => user, :account => account)
end

Given /^"([^"]*)" is an admin of the "([^"]*)" account/ do |email, account_name|
  user = User.find_by_email!(email)
  account = Account.find_by_name!(account_name)
  Factory(:membership, :user => user, :account => account, :admin => true)
end

Then /^the user "([^"]*)" should be an admin of "([^"]*)"$/ do |email, account_name|
  user = User.find_by_email!(email)
  account = Account.find_by_name!(account_name)
  user.should be_admin_of(account)
end

Given /^the user "([^"]*)" exists under the "([^"]*)" account$/ do |email, account_name|
  Given %{a user exists with an email of "#{email}"}
  Given %{"#{email}" is a member of the "#{account_name}" account}
end

When /^I fill in the following new user:$/ do |table|
  within "fieldset.new_user" do
    table.transpose.hashes.first.each do |field, value|
      fill_in field, :with => value
    end
  end
end

When /^I fill in the following existing user:$/ do |table|
  within "fieldset.existing_user" do
    table.transpose.hashes.first.each do |field, value|
      fill_in field, :with => value
    end
  end
end

Then /^"([^"]*)" should be a member of the "([^"]*)" account$/ do |email, account_name|
  User.find_by_email!(email).should be_member_of(Account.find_by_name!(account_name))
end

Then /^"([^"]*)" should be an admin member of the "([^"]*)" account$/ do |email, account_name|
  User.find_by_email!(email).should be_admin_of(Account.find_by_name!(account_name))
end

Then /^"([^"]*)" should be a member of the "([^"]*)" project/ do |email, project_name|
  User.find_by_email!(email).should be_member_of(Project.find_by_name!(project_name))
end

Then /^"([^"]*)" should not be a member of the "([^"]*)" project/ do |email, project_name|
  User.find_by_email!(email).should_not  be_member_of(Project.find_by_name!(project_name))
end

Then /^"([^"]+)" should be listed as an admin$/ do |name|
  within("#project_admins_input") do
    check_box = find_field(name)
    check_box['checked'].should be_true
    check_box['disabled'].should be_true
  end
end

Then /^"([^"]+)" should be listed as a member/ do |name|
  within("#project_users_input") do
    check_box = find_field(name)
    check_box['checked'].should be_true
    check_box['disabled'].should be_false
  end
end

Then /^"([^"]+)" should be listed as a non-member/ do |name|
  within("#project_users_input") do
    check_box = find_field(name)
    check_box['checked'].should be_false
    check_box['disabled'].should be_false
  end
end

