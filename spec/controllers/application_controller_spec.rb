require 'spec_helper'

describe ApplicationController do

  describe "with a valid account id in the params" do
    before do
      @account = Factory(:account)
      @controller.stubs(:params).returns(:account_id => @account.to_param)
    end

    it "should return the corresponding account from current_account" do
      @controller.__send__(:current_account).should == @account
    end
  end

  describe "with an invalid account id in the params" do
    before do
      @controller.stubs(:params).returns(:account_id => "invalid")
    end

    it "should return the corresponding account from current_account" do
      expect { @controller.__send__(:current_account) }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it { should filter_param(:card_number) }
  it { should filter_param(:cardholder_name) }
  it { should filter_param(:verification_code) }
  it { should filter_param(:expiration_month) }
  it { should filter_param(:expiration_year) }
end
