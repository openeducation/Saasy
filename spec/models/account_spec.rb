require 'spec_helper'

describe Account do
  subject { Factory(:account) }

  it { should have_many(:memberships) }
  it { should have_many(:users).through(:memberships) }
  it { should have_many(:projects) }
  it { should belong_to(:plan) }

  it { should validate_uniqueness_of(:keyword) }
  it { should validate_presence_of(  :name) }
  it { should validate_presence_of(:keyword) }
  it { should validate_presence_of(:plan_id) }

  it { should allow_value("hello").for(:keyword) }
  it { should allow_value("0123").for(:keyword) }
  it { should allow_value("hello_world").for(:keyword) }
  it { should allow_value("hello-world").for(:keyword) }
  it { should_not allow_value("HELLO").for(:keyword) }
  it { should_not allow_value("hello world").for(:keyword) }

  it { should_not allow_mass_assignment_of(:id) }
  it { should_not allow_mass_assignment_of(:updated_at) }
  it { should_not allow_mass_assignment_of(:created_at) }
  it { should allow_mass_assignment_of(:keyword) }

  [nil, "", "a b", "a.b", "a%b"].each do |value|
    it { should_not allow_value(value).for(:keyword).with_message(/letters/i) }
  end

  ["foo", "f00", "37signals"].each do |value|
    it { should allow_value(value).for(:keyword) }
  end

  it "should give its keyword for to_param" do
    subject.to_param.should == subject.keyword
  end

  it "finds admin users" do
    admins = [Factory(:user), Factory(:user)]
    non_admin = Factory(:user)
    non_member = Factory(:user)
    admins.each do |admin|
      Factory(:membership, :user => admin, :account => subject, :admin => true)
    end
    Factory(:membership, :user => non_admin, :account => subject, :admin => false)

    result = subject.admins

    result.to_a.should =~ admins
  end

  it "finds non admin users" do
    non_admins = [Factory(:user), Factory(:user)]
    admin = Factory(:user)
    non_member = Factory(:user)
    non_admins.each do |non_admin|
      Factory(:membership, :user => non_admin, :account => subject, :admin => false)
    end
    Factory(:membership, :user => admin, :account => subject, :admin => true)

    result = subject.non_admins

    result.to_a.should =~ non_admins
  end

  it "finds emails for admin users" do
    admins = [Factory(:user), Factory(:user)]
    non_admin = Factory(:user)
    non_member = Factory(:user)
    admins.each do |admin|
      Factory(:membership, :user => admin, :account => subject, :admin => true)
    end
    Factory(:membership, :user => non_admin, :account => subject, :admin => false)

    subject.admin_emails.should == admins.map(&:email)
  end

  it "has a member with a membership" do
    membership = Factory(:membership, :account => subject)
    should have_member(membership.user)
  end

  it "has a count of users" do
    membership = Factory(:membership, :account => subject)
    subject.users_count.should == 1
  end

  it "has a count of active projects" do
    Factory(:project, :account => subject, :archived => false)
    Factory(:project, :account => subject, :archived => true)
    subject.projects_count.should == 1
  end

  it "doesn't have a member without a membership" do
    membership = Factory(:membership, :account => subject)
    should_not have_member(Factory(:user))
  end

  it "finds memberships by name" do
    expected = 'expected result'
    memberships = stub('memberships', :by_name => expected)
    account = Factory.stub(:account)
    account.stubs(:memberships => memberships)

    result = account.memberships_by_name

    result.should == expected
  end

  it "is expired with a trial plan after 30 days" do
    trial = Factory(:plan, :trial => true)
    Factory(:account, :created_at => 30.days.ago, :plan => trial).should be_expired
  end

  it "isn't expired with a trial plan before 30 days" do
    trial = Factory(:plan, :trial => true)
    Factory(:account, :created_at => 29.days.ago, :plan => trial).should_not be_expired
  end

  it "isn't expired with a non-trial plan after 30 days" do
    forever = Factory(:plan, :trial => false)
    Factory(:account, :created_at => 30.days.ago, :plan => forever).should_not be_expired
  end

  it "isn't expired without an expiration date after 30 days" do
    trial = Factory(:plan, :trial => true)
    account = Factory(:account, :created_at => 30.days.ago, :plan => trial)
    account.trial_expires_at = nil
    account.save!
    account.should_not be_expired
  end

  it "sends notifications for expiring accounts" do
    trial   = Factory(:plan, :trial => true)
    forever = Factory(:plan, :trial => false)

    created_23_days  = Factory(:account, :plan => trial, :created_at => 23.days.ago)
    expires_7_days   = Factory(:account, :plan => trial, :created_at => 1.day.ago)
    expiring         = [created_23_days, expires_7_days]
    forever          = Factory(:account, :plan => forever, :created_at => 23.days.ago)
    new_trial        = Factory(:account, :plan => trial, :created_at => 22.days.ago)
    already_notified = Factory(:account, :plan                   => trial,
                                         :created_at             => 24.days.ago,
                                         :notified_of_expiration => true)

    expires_7_days.trial_expires_at = 7.days.from_now
    expires_7_days.save!

    mail = stub('mail', :deliver => true)
    BillingMailer.stubs(:expiring_trial => mail)

    Account.deliver_expiring_trial_notifications

    expiring.each do |account|
      BillingMailer.should have_received(:expiring_trial).with(account)
    end

    mail.should have_received(:deliver).twice

    expiring.each { |account| account.reload.should be_notified_of_expiration }
  end

  it "sends notifications for completed trials" do
    trial   = Factory(:plan, :trial => true)
    forever = Factory(:plan, :trial => false)

    unexpired_trial          = Factory(:account, :plan => trial, :created_at => 29.days.ago)
    unnotified_expired_trial = Factory(:account, :plan => trial, :created_at => 31.days.ago)
    expiring_now             = Factory(:account, :plan => trial, :created_at => 1.day.ago)
    notified_expired_trial   = Factory(:account, :plan                         => trial,
                                                 :created_at                   => 31.days.ago,
                                                 :notified_of_completed_trial  => true)
    forever                  = Factory(:account, :plan => forever, :created_at => 31.days.ago)

    expiring_now.trial_expires_at = 1.day.ago
    expiring_now.save!

    requires_notification = [unnotified_expired_trial, expiring_now]

    mail = stub('mail', :deliver => true)
    BillingMailer.stubs(:completed_trial => mail)

    Account.deliver_completed_trial_notifications

    requires_notification.each do |account|
      BillingMailer.should have_received(:completed_trial).with(account)
    end

    mail.should have_received(:deliver).twice

    requires_notification.each { |account| account.reload.should be_notified_of_completed_trial }
  end

  it "sends notifications for unactivated accounts after 7 days" do
    unactivated = [Factory(:account, :created_at => 7.days.ago),
                   Factory(:account, :created_at => 8.days.ago)]
    fresh = Factory(:account, :created_at => 6.days.ago)
    activated = Factory(:account, :created_at => 9.days.ago, :activated => true)
    already_notified = Factory(:account, :created_at        => 9.days.ago,
                                         :asked_to_activate => true)

    mail = stub('mail', :deliver => true)
    BillingMailer.stubs(:new_unactivated => mail)

    Account.deliver_new_unactivated_notifications

    unactivated.each do |account|
      BillingMailer.should have_received(:new_unactivated).with(account)
    end

    mail.should have_received(:deliver).twice

    unactivated.each { |account| account.reload.should be_asked_to_activate }
  end
end

