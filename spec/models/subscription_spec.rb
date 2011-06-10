require 'spec_helper'

describe Account do
  subject { Factory(:account) }

  it "manifests braintree processor_declined errors as errors on number and doesn't save" do
    FakeBraintree.failures["4111111111111112"] = { "message" => "Do Not Honor", "code" => "2000", "status" => "processor_declined" }
    account = Factory.build(:account, 
                            :cardholder_name => "Ralph Robot", 
                            :billing_email => "ralph@example.com", 
                            :card_number => "4111111111111112", 
                            :verification_code => "100",
                            :expiration_month => 5, 
                            :expiration_year => 2012,
                            :plan => Factory(:paid_plan))
    account.save.should_not be
    FakeBraintree.customers.should be_empty
    account.persisted?.should_not be
    account.errors[:card_number].any? { |e| e =~ /denied/ }.should be
  end

  it "manifests braintree gateway_rejected errors as errors on number and doesn't save" do
    FakeBraintree.failures["4111111111111112"] = { "message" => "Gateway Rejected: cvv", "code" => "N", "status" => "gateway_rejected" }
    account = Factory.build(:account, 
                            :cardholder_name => "Ralph Robot", 
                            :billing_email => "ralph@example.com", 
                            :card_number => "4111111111111112", 
                            :expiration_month => 5, 
                            :expiration_year => 2012,
                            :verification_code => 200,
                            :plan => Factory(:paid_plan))
    account.save.should_not be
    FakeBraintree.customers.should be_empty
    account.persisted?.should_not be
    account.errors[:verification_code].any? { |e| e =~ /did not match/ }.should be
   end

  it "manifests braintree gateway_rejected errors as errors on number and doesn't save" do
    FakeBraintree.failures["4111111111111111"] = { "message" => "Credit card number is invalid.", "errors" => { "customer" => { "errors" => [], "credit-card" => { "errors" => [{ "message" => "Credit card number is invalid.", "code" => 81715, "attribute" => :number }] }}}}
    account = Factory.build(:account, 
                            :cardholder_name => "Ralph Robot", 
                            :billing_email => "ralph@example.com", 
                            :card_number => "4111111111111111", 
                            :expiration_month => 5, 
                            :expiration_year => 2012,
                            :verification_code => 123,
                            :plan => Factory(:paid_plan))
    account.save.should_not be
    FakeBraintree.customers.should be_empty
    account.persisted?.should_not be
    account.errors[:card_number].any? { |e| e =~ /is invalid/ }.should be
   end
end

describe Account, "given free and paid plans" do
  let(:free) { Factory(:plan, :price => 0) }
  let(:paid) { Factory(:plan, :price => 1) }

  it "doesn't switch from free to paid without credit card info" do
    account = Factory(:account, :plan => free)
    account = Account.find(account.id)

    result = account.save_customer_and_subscription!(:plan_id => paid.id)

    result.should be_false
    account.reload.plan.should == free
    Saucy::Subscription::CUSTOMER_ATTRIBUTES.keys.each do |attribute|
      account.errors[attribute].should_not be_blank
    end
    FakeBraintree.customers[account.customer_token].should_not be_nil
    FakeBraintree.customers[account.customer_token]["credit_cards"].should be_blank
  end

  it "requires a billing email when upgrading to a paid plan" do
    account = Factory(:account, :plan => free, :card_number => '123')
    account.reload
    account.plan = paid

    account.should validate_presence_of(:billing_email)
  end

  it "requires a billing email for paid plans" do
    account = Factory.build(:account, :plan => paid, :card_number => '123')
    account.should validate_presence_of(:billing_email)
  end

  it "doesn't require a billing email for free plans" do
    account = Factory.build(:account, :plan => free)
    account.should_not validate_presence_of(:billing_email)
  end
end

describe Account, "with a paid plan" do
  subject do
    Factory(:account, 
            :cardholder_name => "Ralph Robot", 
            :billing_email => "ralph@example.com", 
            :card_number => "4111111111111111", 
            :verification_code => "123",
            :expiration_month => 5, 
            :expiration_year => 2012,
            :plan => Factory(:paid_plan))
  end

  it "has a customer_token" do
    subject.customer_token.should_not be_nil
  end

  it "has a subscription_token" do
    subject.subscription_token.should_not be_nil
  end

  it "has a customer" do
    subject.customer.should_not be_nil
  end

  it "has a credit card" do
    subject.credit_card.should_not be_nil
  end

  it "has a subscription" do
    subject.subscription.should_not be_nil
  end

  it "has a next_billing_date" do
    subject.next_billing_date.should_not be_nil
  end

  it "has an active subscription status" do
    subject.subscription_status.should == Braintree::Subscription::Status::Active
  end

  it "is not past due" do
    subject.past_due?.should_not be
  end

  it "creates a braintree customer, credit card, and subscription" do
    FakeBraintree.customers[subject.customer_token].should_not be_nil
    FakeBraintree.customers[subject.customer_token]["credit_cards"].first.should_not be_nil
    FakeBraintree.subscriptions[subject.subscription_token].should_not be_nil
  end

  it "changes the subscription when the plan is changed" do
    new_plan = Factory(:paid_plan, :name => "New Plan")
    subject.save_customer_and_subscription!(:plan_id => new_plan.id)
    FakeBraintree.subscriptions[subject.subscription_token]["plan_id"].should == new_plan.id
  end

  it "updates the customer and credit card information when changed" do
    subject.save_customer_and_subscription!(:billing_email => "jrobot@example.com",
                                            :cardholder_name => "Jim Robot", 
                                            :card_number => "4111111111111115",
                                            :verification_code => "123",
                                            :expiration_month => 5, 
                                            :expiration_year => 2013)
    subject.customer.email.should == "jrobot@example.com"
    subject.credit_card.cardholder_name.should == "Jim Robot"
  end

  it "deletes the customer when deleted" do
    subject.destroy
    FakeBraintree.customers[subject.customer_token].should be_nil
  end
end

describe Account, "with a free plan" do
  subject do
    Factory(:account, :plan => Factory(:plan))
  end

  it "has a customer_token" do
    subject.customer_token.should_not be_nil
  end

  it "has a customer" do
    subject.customer.should_not be_nil
  end

  it "doesn't have a credit_card" do
    subject.credit_card.should be_nil
  end

  it "doesn't have a subscription_token" do
    subject.subscription_token.should be_nil
  end

  it "doesn't have a subscription" do
    subject.subscription.should be_nil
  end

  it "creates a braintree customer" do
    FakeBraintree.customers[subject.customer_token].should_not be_nil
  end

  it "doesn't create a credit card, and subscription" do
    FakeBraintree.customers[subject.customer_token]["credit_cards"].should be_nil
    FakeBraintree.subscriptions[subject.subscription_token].should be_nil
  end

  it "creates a credit card, and subscription when the plan is changed to a paid plan and the billing info is supplied" do
    new_plan = Factory(:paid_plan, :name => "New Plan")
    subject.save_customer_and_subscription!(:plan_id => new_plan.id,
                                            :cardholder_name => "Ralph Robot", 
                                            :billing_email => "ralph@example.com", 
                                            :card_number => "4111111111111111", 
                                            :verification_code => "123",
                                            :expiration_month => 5, 
                                            :expiration_year => 2012)

    FakeBraintree.customers[subject.customer_token]["credit_cards"].first.should_not be_nil
    FakeBraintree.subscriptions[subject.subscription_token].should_not be_nil
    FakeBraintree.subscriptions[subject.subscription_token]["plan_id"].should == new_plan.id
    subject.credit_card.should_not be_nil
    subject.subscription.should_not be_nil
  end

  it "passes up the merchant_account_id on the subscription when it's configured" do
    begin
      Saucy::Configuration.merchant_account_id = 'test'
      new_plan = Factory(:paid_plan, :name => "New Plan")
      subject.save_customer_and_subscription!(:plan_id => new_plan.id,
                                              :cardholder_name => "Ralph Robot", 
                                              :billing_email => "ralph@example.com", 
                                              :card_number => "4111111111111111", 
                                              :verification_code => "123",
                                              :expiration_month => 5, 
                                              :expiration_year => 2012)

      FakeBraintree.subscriptions[subject.subscription_token]["merchant_account_id"].should == 'test'
    ensure
      Saucy::Configuration.merchant_account_id = nil
    end
  end

  it "doesn't pass up the merchant_account_id on the subscription when it's not configured" do
    Saucy::Configuration.merchant_account_id = nil
    new_plan = Factory(:paid_plan, :name => "New Plan")
    subject.save_customer_and_subscription!(:plan_id => new_plan.id,
                                            :cardholder_name => "Ralph Robot", 
                                            :billing_email => "ralph@example.com", 
                                            :card_number => "4111111111111111", 
                                            :verification_code => "123",
                                            :expiration_month => 5, 
                                            :expiration_year => 2012)

    FakeBraintree.subscriptions[subject.subscription_token].keys.should_not include("merchant_account_id")
  end

  it "doesn't create a credit card, and subscription when the plan is changed to a different free plan" do
    new_plan = Factory(:plan, :name => "New Plan")
    subject.save_customer_and_subscription!(:plan_id => new_plan.id)

    subject.credit_card.should be_nil
    subject.subscription.should be_nil
  end
end

describe Account, "with a plan and limits, and other plans" do
  subject { Factory(:account) }

  before do
    Factory(:limit, :name => "users", :value => 1, :plan => subject.plan)
    Factory(:limit, :name => "projects", :value => 1, :plan => subject.plan)
    Factory(:limit, :name => "ssl", :value => 1, :value_type => :boolean, :plan => subject.plan)
    @can_switch = Factory(:plan)
    Factory(:limit, :name => "users", :value => 1, :plan => @can_switch)
    Factory(:limit, :name => "projects", :value => 1, :plan => @can_switch)
    Factory(:limit, :name => "ssl", :value => 0, :value_type => :boolean, :plan => @can_switch)
    @cannot_switch = Factory(:plan)
    Factory(:limit, :name => "users", :value => 0, :plan => @cannot_switch)
    Factory(:limit, :name => "projects", :value => 0, :plan => @cannot_switch)
    Factory(:limit, :name => "ssl", :value => 1, :value_type => :boolean, :plan => @cannot_switch)

    Factory(:membership, :account => subject)
    Factory(:project, :account => subject)
  end

  it "indicates whether the account can switch to another plan" do
    subject.can_change_plan_to?(@can_switch).should be
    subject.can_change_plan_to?(@cannot_switch).should_not be
  end
end

describe Account, "with a paid subscription" do
  subject do
    Factory(:account, 
            :cardholder_name => "Ralph Robot", 
            :billing_email => "ralph@example.com", 
            :card_number => "4111111111111111", 
            :verification_code => "123",
            :expiration_month => 5, 
            :expiration_year => 2012,
            :plan => Factory(:paid_plan))
  end

  it "gets marked as past due and updates its next_billing_date when subscriptions are updated and it has been rejected by the gateway" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::PastDue
    subscription["next_billing_date"] = 2.months.from_now

    Timecop.travel(subject.next_billing_date + 1.day) do
      Account.update_subscriptions!
      subject.reload.subscription_status.should == Braintree::Subscription::Status::PastDue
      subject.next_billing_date.to_s.should == subscription["next_billing_date"].to_s
      subject.past_due?.should be
    end
  end

  it "gets marked as not past due and updates its next_billing_date when the subscription is active after its billing date" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::Active
    subscription["next_billing_date"] = 2.months.from_now
    FakeBraintree.transaction = { :status => Braintree::Transaction::Status::Settled,
                                  :subscription_id => subject.subscription_token }
    subscription["transactions"] = [FakeBraintree.generated_transaction]

    Timecop.travel(subject.next_billing_date + 1.day) do
      Account.update_subscriptions!
      subject.reload.subscription_status.should == Braintree::Subscription::Status::Active
      subject.next_billing_date.to_s.should == subscription["next_billing_date"].to_s
    end
  end

  it "receives a receipt email at it's billing email with transaction details" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::Active
    subscription["next_billing_date"] = 2.months.from_now
    FakeBraintree.transaction = { :status => Braintree::Transaction::Status::Settled,
                                  :subscription_id => subject.subscription_token }
    subscription["transactions"] = [FakeBraintree.generated_transaction]

    Timecop.travel(subject.next_billing_date + 1.day) do
      ActionMailer::Base.deliveries.clear

      Account.update_subscriptions!

      ActionMailer::Base.deliveries.any? do |email|
        email.to == [subject.billing_email] &&
        email.subject =~ /receipt/i
      end.should be
    end
  end

  it "doesn't receive a receipt email when it's already been billed" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::Active
    subscription["next_billing_date"] = 2.months.from_now
    FakeBraintree.transaction = { :status => Braintree::Transaction::Status::Settled,
                                  :subscription_id => subject.subscription_token }
    subscription["transactions"] = [FakeBraintree.generated_transaction]

    Timecop.travel(subject.next_billing_date - 1.day) do
      ActionMailer::Base.deliveries.clear

      Account.update_subscriptions!

      ActionMailer::Base.deliveries.select do |email|
        email.to == [subject.billing_email] &&
        email.subject =~ /receipt/i
      end.should be_empty
    end
  end

  it "receives a receipt email at it's billing email with a notice that it failed when billing didn't work" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::PastDue
    subscription["next_billing_date"] = 2.months.from_now
    FakeBraintree.transaction = { :status => Braintree::Transaction::Status::Failed,
                                  :subscription_id => subject.subscription_token }
    subscription["transactions"] = [FakeBraintree.generated_transaction]

    Timecop.travel(subject.next_billing_date + 1.day) do
      ActionMailer::Base.deliveries.clear

      Account.update_subscriptions!

      ActionMailer::Base.deliveries.any? do |email|
        email.to == [subject.billing_email] &&
        email.subject =~ /problem/i
      end.should be
    end
  end
end

describe Account, "with a paid subscription that is past due" do
  subject do
    Factory(:account, 
            :cardholder_name => "Ralph Robot", 
            :billing_email => "ralph@example.com", 
            :card_number => "4111111111111111", 
            :verification_code => "123",
            :expiration_month => 5, 
            :expiration_year => 2012,
            :plan => Factory(:paid_plan))
  end

  before do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::PastDue
    subscription["next_billing_date"] = 2.months.from_now

    Timecop.travel(subject.next_billing_date + 1.day) do
      Account.update_subscriptions!
    end
    subject.reload
  end

  it "retries the subscription charge and updates the subscription when the billing information is correctly updated" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::Active
    subscription["next_billing_date"] = 2.months.from_now
    FakeBraintree.transaction = { :status => Braintree::Transaction::Status::Settled,
                                  :subscription_id => subject.subscription_token }
    transaction = FakeBraintree.generated_transaction
    subscription["transactions"] = [transaction]

    retry_transaction = stub(:id => "12345")
    retry_authorization = stub(:transaction => retry_transaction)

    Braintree::Subscription.expects(:retry_charge).with(subject.subscription_token).returns(retry_authorization)
    Braintree::Transaction.expects(:submit_for_settlement).with(retry_transaction.id).returns(stub(:success? => true))

    subject.save_customer_and_subscription!(:card_number => "4111111111111111",
                                            :verification_code => "124",
                                            :expiration_month => 6,
                                            :expiration_year => 2012).should be

    subject.reload.subscription_status.should == Braintree::Subscription::Status::Active
    subject.next_billing_date.to_s.should == subscription["next_billing_date"].to_s
  end

  it "retries the subscription charge and updates the subscription when the payment processing fails" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::PastDue
    subscription["next_billing_date"] = 1.day.from_now
    FakeBraintree.transaction = { :status => Braintree::Transaction::Status::Failed,
                                  :subscription_id => subject.subscription_token }
    transaction = FakeBraintree.generated_transaction
    subscription["transactions"] = [transaction]

    retry_transaction = stub(:id => "12345", :status => "processor_declined", "processor_response_text" => "no good")
    retry_authorization = stub(:transaction => retry_transaction)

    Braintree::Subscription.expects(:retry_charge).with(subject.subscription_token).returns(retry_authorization)
    Braintree::Transaction.expects(:submit_for_settlement).with(retry_transaction.id).returns(stub(:success? => false, :errors => []))

    subject.save_customer_and_subscription!(:card_number => "4111111111",
                                            :verification_code => "124",
                                            :expiration_month => 6,
                                            :expiration_year => 2012).should_not be

    subject.errors[:card_number].should include("was denied by the payment processor with the message: no good")
    subject.reload.subscription_status.should == Braintree::Subscription::Status::PastDue
    subject.next_billing_date.to_s.should == subscription["next_billing_date"].to_s
  end

  it "retries the subscription charge and updates the subscription when the settlement fails" do
    subscription = FakeBraintree.subscriptions[subject.subscription_token]
    subscription["status"] = Braintree::Subscription::Status::PastDue
    subscription["next_billing_date"] = 1.day.from_now
    FakeBraintree.transaction = { :status => Braintree::Transaction::Status::Failed,
                                  :subscription_id => subject.subscription_token }
    transaction = FakeBraintree.generated_transaction
    subscription["transactions"] = [transaction]

    retry_transaction = stub(:id => "12345", :status => "")
    retry_authorization = stub(:transaction => retry_transaction)

    Braintree::Subscription.expects(:retry_charge).with(subject.subscription_token).returns(retry_authorization)
    Braintree::Transaction.expects(:submit_for_settlement).with(retry_transaction.id).returns(stub(:success? => false, :errors => [stub(:attribute => 'number', :message => 'no good')]))

    subject.save_customer_and_subscription!(:card_number => "4111111111",
                                            :verification_code => "124",
                                            :expiration_month => 6,
                                            :expiration_year => 2012).should_not be

    subject.errors[:card_number].should include("no good")
    subject.reload.subscription_status.should == Braintree::Subscription::Status::PastDue
    subject.next_billing_date.to_s.should == subscription["next_billing_date"].to_s
  end
end
