require 'spec_helper'

describe Limit do
  subject { Factory(:limit) }

  it { should belong_to(:plan) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:value) }
end

describe Limit, "various kinds" do
  let!(:users) { Factory(:limit, :name => "users", :value => 1) }
  let!(:ssl) { Factory(:limit, :name => "ssl", :value => 0, :value_type => :boolean) }
  let!(:lighthouse) { Factory(:limit, :name => "lighthouse", :value => 1, :value_type => :boolean) }

  it "gives the numbered limits" do
    Limit.numbered.should == [users]
  end

  it "gives the boolean limits" do
    Limit.boolean.should == [ssl, lighthouse]
  end

  it "gives the limits by name" do
    Limit.named(:users).should == users
  end

  it "reports true for booleans with 1" do
    lighthouse.allowed?.should be
  end

  it "reports false for booleans with 0" do
    ssl.allowed?.should_not be
  end
end

describe Limit, "with account and limits" do
  subject { Factory(:limit, :name => "users", :value => 1) }

  before do
    @account = Factory(:account, :plan => subject.plan)
  end

  it "indicates whether the account is below the limit" do
    subject.within?(@account)
  end

  it "gives the current count for the account of the limit" do
    @account.stubs(:users_count => 99)
    subject.current_count(@account).should == 99
  end

  it "can query whether the given account is below the specified limit" do
    Limit.within?("users", @account)
  end

  it "indicates whether the specified account can add one" do
    Limit.can_add_one?("users", @account).should be
   
    Factory(:membership, :account => @account)
    Factory(:project, :account => @account)

    Limit.can_add_one?("users", @account).should_not be
  end

  it "returns true if there is no limit" do
    Limit.can_add_one?("nomatch", @account).should be
    Limit.within?("nomatch", @account).should be
  end
end
