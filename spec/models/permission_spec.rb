require 'spec_helper'

describe Permission do
  it { should belong_to(:project) }
  it { should belong_to(:membership) }
  it { should belong_to(:user) }

  it "doesn't allow the same member to be added to a project twice" do
    original = Factory(:permission)
    duplicate = Factory.build(:permission, :membership => original.membership, :project => original.project)
    duplicate.should_not be_valid
  end

  it "allows different members to be added to a project" do
    original = Factory(:permission)
    duplicate = Factory.build(:permission, :project => original.project)
    duplicate.should be_valid
  end

  it "caches the user from the account membership" do
    membership = Factory(:membership)
    permission = Factory(:permission, :membership => membership)
    permission.user_id.should == membership.user_id
  end

  it "doesn't allow the user to be assigned" do
    expect { subject.user = Factory.build(:user) }.to raise_error
  end
end

