require 'spec_helper'

describe PlansController, "successful update", :as => :account_admin do
  before do
    Account.stubs(:find_by_keyword! => account)
    account.stubs(:save_customer_and_subscription! => true)
    put :update, :account_id => account.to_param
  end

  it "notifies observers" do
    should notify_observers("plan_upgraded", :account => account, :request => request)
  end
end
