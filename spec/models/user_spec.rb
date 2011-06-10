require 'spec_helper'

describe User, "valid" do
  subject { Factory(:user) }

  it { should validate_presence_of(:name) }

  it { should have_many(:memberships) }
  it { should have_many(:accounts).through(:memberships) }
  it { should have_many(:permissions) }
  it { should have_many(:projects).through(:permissions) }

  it "is an admin of an account with an admin membership" do
    account = Factory(:account)
    Factory(:membership, :user => subject, :admin => true, :account => account)
    subject.should be_admin_of(account)

    subject.memberships.admin.first.account.should == account
  end

  it "isn't an admin of an account with a non admin membership" do
    account = Factory(:account)
    Factory(:membership, :user => subject, :admin => false, :account => account)
    subject.should_not be_admin_of(account)
  end

  it "isn't an admin of an account without a membership" do
    account = Factory(:account)
    subject.should_not be_admin_of(account)
  end

  it "is a member with a membership for the given account" do
    account = Factory(:account)
    Factory(:membership, :user => subject, :account => account)
    subject.should be_member_of(account)
  end

  it "isn't a member without a membership for the given account" do
    account = Factory(:account)
    other_account = Factory(:account)
    Factory(:membership, :user => subject, :account => other_account)
    subject.should_not be_member_of(account)
  end

  it "is a member with a membership for the given project" do
    project = Factory(:project)
    membership = Factory(:membership, :user    => subject,
                                                      :account => project.account)
    Factory(:permission, :membership => membership,
                                 :project            => project)
    subject.should be_member_of(project)
  end

  it "isn't a member without a membership for the given project" do
    project = Factory(:project)
    other_project = Factory(:project)
    membership = Factory(:membership, :user    => subject,
                                                      :account => other_project.account)
    Factory(:permission, :membership => membership,
                                 :project            => other_project)
    subject.should_not be_member_of(project)
  end

  it "returns users by name" do
    Factory(:user, :name => "def")
    Factory(:user, :name => "abc")
    Factory(:user, :name => "ghi")

    User.by_name.map(&:name).should == %w(abc def ghi)
  end
end

