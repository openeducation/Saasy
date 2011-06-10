require 'spec_helper'

describe Saucy::Configuration do
  it "has layouts" do
    subject.layouts.should be_a(Saucy::Layouts)
  end

  it "has a manager_email_address" do
    subject.manager_email_address.should_not be_nil
  end

  it "has a support_email_address" do
    subject.support_email_address.should_not be_nil
  end

  it "has a nil merchant_account_id" do
    subject.merchant_account_id.should be_nil
  end

  it "can listen for events" do
    observer = stub("an observer")
    cleanup_observers do
      Saucy::Configuration.observe(observer)
      Saucy::Configuration.observers.should include(observer)
    end
  end

  it "can notify observers" do
    observer = stub("an observer", :some_event => nil)
    cleanup_observers do
      Saucy::Configuration.observe(observer)
      Saucy::Configuration.notify("some_event", "some_data")
      observer.should have_received("some_event").with("some_data")
    end
  end

  it "can assign a manager email address" do
    old_address = subject.manager_email_address
    begin
      subject.manager_email_address = 'newsender@example.com'
      subject.manager_email_address.should == 'newsender@example.com'
    ensure
      subject.manager_email_address = old_address
    end
  end

  it "can assign a support email address" do
    old_address = subject.support_email_address
    begin
      subject.support_email_address = 'newsender@example.com'
      subject.support_email_address.should == 'newsender@example.com'
    ensure
      subject.support_email_address = old_address
    end
  end

  def cleanup_observers
    yield
  ensure
    subject.observers.clear
  end
end
