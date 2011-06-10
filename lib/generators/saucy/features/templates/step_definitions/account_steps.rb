Given /^an? "([^"]+)" account exists with a name of "([^"]*)" created (\d+) days ago$/ do |plan_name, account_name, days|
  plan = Plan.find_by_name!(plan_name)
  Factory(:account, :created_at => days.to_i.days.ago, :plan => plan, :name => account_name)
end

Given /^the "([^"]*)" account was created (\d+) days ago$/ do |account_name, days|
  Account.find_by_name!(account_name).tap do |account|
    account.created_at = days.to_i.days.ago
    account.save!
  end
end

Given /^the following limit exists for the "([^"]*)" account:$/ do |account_name, table|
  Account.find_by_name!(account_name).tap do |account|
    table.hashes.each do |limit|
      account.plan.limits.create!(limit)
    end
  end
end

When /^I follow "([^"]*)" for the "([^"]*)" account$/ do |link_text, account_name|
  account = Account.find_by_name!(account_name)
  within "##{dom_id(account)}" do
    click_link link_text
  end
end

Then /^I should see (\d+) accounts?$/ do |count|
  page.all("#user_accounts li").size.should == count.to_i
end
