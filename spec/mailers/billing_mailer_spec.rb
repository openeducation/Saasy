require 'spec_helper'

describe "with an account and transaction" do
  let(:account) { Factory(:paid_account) }

  before do
    subscription = FakeBraintree.subscriptions[account.subscription_token]
    subscription["transactions"] = [FakeBraintree.generated_transaction]
  end

  describe BillingMailer, "receipt" do
    subject { BillingMailer.receipt(account, account.subscription.transactions.first) }

    it "sends the receipt mail from the support address" do
      subject.from.should == [Saucy::Configuration.support_email_address]
    end

    it "sets the receipt mail reply-to to the support address" do
      subject.reply_to.should == [Saucy::Configuration.support_email_address]
    end
  end

  describe BillingMailer, "problem" do
    subject { BillingMailer.problem(account, account.subscription.transactions.first) }

    it "sends the problem mail from the support address" do
      subject.from.should == [Saucy::Configuration.support_email_address]
    end

    it "sets the problem mail reply-to to the support address" do
      subject.reply_to.should == [Saucy::Configuration.support_email_address]
    end
  end

  describe BillingMailer, "expiring trial" do
    subject { BillingMailer.expiring_trial(account) }

    it "sends the expiring trial mail from the support address" do
      subject.from.should == [Saucy::Configuration.manager_email_address]
    end

    it "sets the expiring trial mail reply-to to the support address" do
      subject.reply_to.should == [Saucy::Configuration.support_email_address]
    end
  end

  describe BillingMailer, "new unactivated" do
    subject { BillingMailer.expiring_trial(account) }

    it "sends the new unactivated mail from the support address" do
      subject.from.should == [Saucy::Configuration.manager_email_address]
    end

    it "sets the new unactivated mail reply-to to the support address" do
      subject.reply_to.should == [Saucy::Configuration.support_email_address]
    end
  end

  describe BillingMailer, "completed trial" do
    subject { BillingMailer.completed_trial(account) }

    it "uses the completed trial notice" do
      notice = I18n.translate!("billing_mailer.completed_trial.notice",
                               :account_name => account.name)
      subject.body.should include(notice)
    end
  end
end
