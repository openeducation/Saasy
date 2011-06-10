require 'spec_helper'

describe Invitation do
  it { should validate_presence_of(:account_id) }
  it { should validate_presence_of(:email) }
  it { should belong_to(:account) }
  it { should belong_to(:sender) }
  it { should have_and_belong_to_many(:projects) }

  it { should_not allow_mass_assignment_of(:account_id) }
  it { should_not allow_mass_assignment_of(:used) }

  %w(new_user_name new_user_email new_user_password authenticating_user_password).each do |attribute|
    it "allows assignment of #{attribute}" do
      should respond_to(attribute)
      should respond_to(:"#{attribute}=")
    end
  end
end

describe Invitation, "saved" do
  let(:mail)    { stub('invitation', :deliver => true) }
  subject       { Factory(:invitation) }
  let(:email)   { subject.email }
  let(:code)    { 'abchex123' }

  before do
    SecureRandom.stubs(:hex => code)
    InvitationMailer.stubs(:invitation => mail)
    subject
  end

  it "sends an invitation email" do
    InvitationMailer.should have_received(:invitation).with(subject)
    mail.should have_received(:deliver)
  end

  it "delegates account name" do
    subject.account_name.should == subject.account.name
  end

  it "defauls new user email to invited email" do
    subject.new_user_email.should == subject.email
  end

  it "defauls existing user email to invited email" do
    subject.authenticating_user_email.should == subject.email
  end

  it "generates a code" do
    SecureRandom.should have_received(:hex).with(8)
    subject.code.should == code
  end

  it "uses the code in the url" do
    subject.to_param.should == code
  end

  it "delegates sender email" do
    subject.sender_email.should == subject.sender.email
  end

  it "delegates sender name" do
    subject.sender_name.should == subject.sender.name
  end
end

describe Invitation, "valid accept for a new user" do
  let(:account)  { Factory(:account) }
  let(:projects) { [Factory(:project, :account => account)] }
  let(:password) { 'secret' }
  let(:name)     { 'Rocket' }
  subject { Factory(:invitation, :account => account, :projects => projects) }

  let!(:result) do
    subject.accept(:new_user_password => password, :new_user_name => name)
  end

  let(:user) { subject.user }

  it "returns true" do
    result.should be_true
  end

  it "creates a saved, confirmed user" do
    user.should_not be_nil
    user.should be_persisted
    user.name.should == name
  end

  it "adds the user to the account" do
    account.users.should include(user)
  end

  it "adds the user to each of the invitation's projects" do
    projects.each do |project|
      user.should be_member_of(project)
    end
  end

  it "marks the invitation as used" do
    subject.reload.should be_used
  end
end

describe Invitation, "invalid accept for a new user" do
  subject { Factory(:invitation) }
  let!(:result) { subject.accept({}) }
  let(:user) { subject.user }
  let(:account) { subject.account }

  it "returns false" do
    result.should be_false
  end

  it "doesn't create a user" do
    user.should be_new_record
  end

  it "adds error messages" do
    subject.errors[:new_user_password].should be_present
  end

  it "doesn't mark the invitation as used" do
    subject.reload.should_not be_used
  end
end

describe Invitation, "valid accept for an existing user authenticating" do
  let(:password) { 'secret' }
  let(:user)     { Factory(:user, :password => password) }
  subject        { Factory(:invitation, :email => user.email) }
  let(:account)  { subject.account }

  let!(:result) do
    subject.accept(:authenticating_user_password => password)
  end

  it "returns true" do
    result.should be_true
  end

  it "adds the user to the account" do
    account.users.should include(user)
  end

  it "marks the invitation as used" do
    subject.reload.should be_used
  end
end

describe Invitation, "accepting with an invalid password" do
  let(:user)    { Factory(:user) }
  subject       { Factory(:invitation, :email => user.email) }
  let(:account) { subject.account }
  let!(:result) { subject.accept(:authenticating_user_password => 'wrong') }

  it "adds error messages" do
    subject.errors[:authenticating_user_password].should be_present
  end

  it "doesn't add the user to the account" do
    subject.account.users.should_not include(subject.user)
  end

  it "returns false" do
    result.should be_false
  end
end

describe Invitation, "valid accept for an existing user specifically set" do
  let(:user)     { Factory(:user) }
  subject        { Factory(:invitation, :email => user.email) }
  let(:account)  { subject.account }

  let!(:result) do
    subject.accept({:existing_user => user})
  end

  it "returns true" do
    result.should be_true
  end

  it "adds the user to the account" do
    account.users.should include(user)
  end

  it "marks the invitation as used" do
    subject.reload.should be_used
  end
end

describe Invitation, "saved" do
  let(:mail)    { stub('invitation', :deliver => true) }
  subject       { Factory(:invitation) }
  let(:email)   { subject.email }
  let(:code)    { 'abchex123' }

  before do
    SecureRandom.stubs(:hex => code)
    InvitationMailer.stubs(:invitation => mail)
    subject
  end

  it "sends an invitation email" do
    InvitationMailer.should have_received(:invitation).with(subject)
    mail.should have_received(:deliver)
  end

  it "delegates account name" do
    subject.account_name.should == subject.account.name
  end

  it "defauls new user email to invited email" do
    subject.new_user_email.should == subject.email
  end

  it "defauls existing user email to invited email" do
    subject.authenticating_user_email.should == subject.email
  end

  it "generates a code" do
    SecureRandom.should have_received(:hex).with(8)
    subject.code.should == code
  end

  it "uses the code in the url" do
    subject.to_param.should == code
  end
end

describe Invitation, "valid accept for a new user" do
  let(:account)  { Factory(:account) }
  let(:projects) { [Factory(:project, :account => account)] }
  let(:password) { 'secret' }
  let(:name)     { 'Rocket' }
  subject { Factory(:invitation, :account => account, :projects => projects) }

  let!(:result) do
    subject.accept(:new_user_password => password, :new_user_name => name)
  end

  let(:user) { subject.user }

  it "returns true" do
    result.should be_true
  end

  it "creates a saved, confirmed user" do
    user.should_not be_nil
    user.should be_persisted
    user.name.should == name
  end

  it "adds the user to the account" do
    account.users.should include(user)
  end

  it "adds the user to each of the invitation's projects" do
    projects.each do |project|
      user.should be_member_of(project)
    end
  end

  it "marks the invitation as used" do
    subject.reload.should be_used
  end
end

describe Invitation, "invalid accept for a new user" do
  subject { Factory(:invitation) }
  let!(:result) { subject.accept({}) }
  let(:user) { subject.user }
  let(:account) { subject.account }

  it "returns false" do
    result.should be_false
  end

  it "doesn't create a user" do
    user.should be_new_record
  end

  it "adds error messages" do
    subject.errors[:new_user_password].should be_present
  end

  it "doesn't mark the invitation as used" do
    subject.reload.should_not be_used
  end
end

describe Invitation, "accepting with an unknown email" do
  subject       { Factory(:invitation, :email => 'unknown') }
  let(:account) { subject.account }
  let!(:result) { subject.accept(:authenticating_user_password => 'secret') }

  it "adds error messages" do
    subject.errors[:authenticating_user_email].should be_present
  end

  it "returns false" do
    result.should be_false
  end
end

describe Invitation, "accepting an admin invite" do
  let(:password) { 'secret' }
  let(:user)     { Factory(:user, :password => password) }
  subject        { Factory(:invitation, :email => user.email, :admin => true) }
  let(:account)  { subject.account }

  let!(:result) do
    subject.accept(:authenticating_user_password => password)
  end

  it "adds the user as an admin" do
    user.should be_admin_of(account)
  end
end
