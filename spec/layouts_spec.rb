require 'spec_helper'

describe Saucy::Layouts do
  it "allows a layout to be assigned" do
    subject.accounts.index = "custom"
    subject.accounts.index.should == "custom"
  end

  it "defaults to the saucy layout" do
    subject.accounts.index.should == "saucy"
  end

  it "selects a layout for a controller" do
    controller = AccountsController.new
    controller.stubs(:action_name => 'index')
    block = subject.class.to_proc

    block.call(controller).should == 'saucy'
  end
end

