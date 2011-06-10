require 'spec_helper'

describe Membership do
  it { should belong_to(:account) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:account_id) }
  it { should validate_presence_of(:user_id) }
  it { should have_many(:permissions).dependent(:destroy) }
  it { should have_many(:projects).through(:permissions) }

  describe "given an existing account membership" do
    before { Factory(:membership) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:account_id) }
  end

  it "delegates the user's name" do
    user = Factory(:user)
    membership = Factory(:membership, :user => user)

    membership.name.should == user.name
  end

  it "delegates the user's email" do
    user = Factory(:user)
    membership = Factory(:membership, :user => user)

    membership.email.should == user.email
  end

  it "returns memberships by name" do
    Factory(:membership, :user => Factory(:user, :name => "def"))
    Factory(:membership, :user => Factory(:user, :name => "abc"))
    Factory(:membership, :user => Factory(:user, :name => "ghi"))

    Membership.by_name.map(&:name).should == %w(abc def ghi)
  end
end
