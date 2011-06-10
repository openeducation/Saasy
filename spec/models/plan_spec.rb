require 'spec_helper'

describe Plan do
  subject { Factory(:plan) }

  it { should have_many(:limits) }
  it { should have_many(:accounts) }
  it { should validate_presence_of(:name) }

  it "finds ordered paid plans" do
    Factory(:plan, :name => "Free", :price => 0)
    Factory(:plan, :name => "Two", :price => 2)
    Factory(:plan, :name => "One", :price => 1)
    Factory(:plan, :name => "Three", :price => 3)

    Plan.paid_by_price.to_a.map(&:name).should == %w(Three Two One)
  end

  it "finds the trial plan" do
    paid = Factory(:plan, :name => "Paid", :price => 1)
    trial = Factory(:plan, :name => "Free", :price => 0)

    Plan.trial.should == trial
  end
end

describe Plan, "free" do
  subject { Factory(:plan) }

  it "is free" do
    subject.free?.should be
  end

  it "is not billed" do
    subject.billed?.should_not be
  end
end

describe Plan, "paid" do
  subject { Factory(:paid_plan) }

  it "is not free" do
    subject.free?.should_not be
  end

  it "is billed" do
    subject.billed?.should be
  end
end

describe Plan, "with limits" do
  subject { Factory(:plan) }

  before do
    Factory(:limit, :name => "users", :value => 1, :plan => subject)
    Factory(:limit, :name => "ssl", :value => 0, :value_type => :boolean, :plan => subject)
    Factory(:limit, :name => "lighthouse", :value => 1, :value_type => :boolean, :plan => subject)
  end

  it "indicates whether or not more users can be created" do
    subject.can_add_more?(:users, 0).should be
    subject.can_add_more?(:users, 1).should_not be
    subject.can_add_more?(:users, 2).should_not be
  end

  it "indicates whether a plan can do something or not" do
    subject.allows?(:ssl).should_not be
    subject.allows?(:lighthouse).should be
  end
end


describe Plan, "with prices" do
  let!(:free) { Factory(:plan, :price => 0) }
  let!(:least) { Factory(:plan, :price => 1) }
  let!(:most) { Factory(:plan, :price => 2) }

  it "gives them from most to least expensive when ordered" do
    Plan.ordered.should == [most, least, free]
  end
end
