Given /^that the credit card "([^"]*)" is invalid$/ do |number|
  FakeBraintree.failures[number] = { "message" => "Credit card number is invalid.", "errors" => { "customer" => { "errors" => [], "credit-card" => { "errors" => [{ "message" => "Credit card number is invalid.", "code" => 81715, "attribute" => :number }] }}}}
end

Given /^that the credit card "([^"]*)" should not be honored$/ do |number|
  FakeBraintree.failures[number] = { "message" => "Do Not Honor", "code" => "2000", "status" => "processor_declined" }
end

Given /^the "([^"]*)" account is past due$/ do |account_name|
  account = Account.find_by_name!(account_name)
  account.update_attribute(:subscription_status, Braintree::Subscription::Status::PastDue)
end

Given /^the following transaction exist for the "([^"]*)" account:$/ do |account_name, table|
  account = Account.find_by_name!(account_name)
  subscription = FakeBraintree.subscriptions[account.subscription_token]
  subscription["transactions"] = []
  table.hashes.each do |transaction|
    FakeBraintree.transaction = { :status => transaction["status"],
                                  :amount => transaction["amount"],
                                  :created_at => Time.parse(transaction["created_at"]),
                                  :subscription_id => account.subscription_token }
    subscription["transactions"] << FakeBraintree.generated_transaction
  end
end
