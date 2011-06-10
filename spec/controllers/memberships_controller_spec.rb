require 'spec_helper'

describe MembershipsController, "routes" do
  it { should route(:get, "/accounts/abc/memberships").
                to(:action => :index, :account_id => 'abc') }
  it { should route(:get, "/accounts/xyz/memberships/abc/edit").
                to(:action => :edit, :account_id => 'xyz', :id => 'abc') }
  it { should route(:put, "/accounts/xyz/memberships/abc").
                to(:action => :update, :account_id => 'xyz', :id => 'abc') }
  it { should route(:delete, "/accounts/xyz/memberships/abc").
                to(:action => :destroy, :account_id => 'xyz', :id => 'abc') }
end

describe MembershipsController, "permissions", :as => :account_member do
  let(:membership) { Factory(:membership, :account => account) }
  it { should deny_access.
                on(:get, :index, :account_id => account.to_param).
                flash(/admin/) }
  it { should deny_access.
                on(:get, :edit, :id         => membership.to_param,
                                :account_id => account.to_param).
                flash(/admin/) }
end

describe MembershipsController, "index", :as => :account_admin do
  let(:memberships) { [Factory.stub(:membership), Factory.stub(:membership)] }

  before do
    Account.stubs(:find_by_keyword! => account)
    account.stubs(:memberships_by_name => memberships)
    get :index, :account_id => account.to_param
  end

  it "renders the index template" do
    should respond_with(:success)
    should render_template(:index)
  end

  it "assigns memberships by name" do
    account.should have_received(:memberships_by_name)
    should assign_to(:memberships).with(memberships)
  end
end

describe MembershipsController, "edit", :as => :account_admin do
  let(:edited_membership) { Factory.stub(:membership, :account => account) }
  let(:projects) { [Factory.stub(:project)] }

  before do
    Membership.stubs(:find => edited_membership)
    account.stubs(:projects_by_name => projects)
    get :edit, :id => edited_membership.to_param, :account_id => account.to_param
  end

  it "renders the edit template" do
    should respond_with(:success)
    should render_template(:edit)
  end

  it "assigns projects by name" do
    account.should have_received(:projects_by_name)
    should assign_to(:projects).with(projects)
  end

  it "assigns the membership being edited" do
    Membership.should have_received(:find).with(edited_membership.to_param,
                                                :include => :account)
    should assign_to(:membership).with(edited_membership)
  end
end

describe MembershipsController, "update", :as => :account_admin do
  let(:edited_membership) { Factory.stub(:membership, :account => account) }
  let(:attributes) { 'some attributes' }

  before do
    Membership.stubs(:find => edited_membership)
    edited_membership.stubs(:update_attributes!)
    put :update, :id         => edited_membership.to_param,
                 :account_id => account.to_param,
                 :membership => attributes
  end

  it "redirects to the account memberships index" do
    should redirect_to(account_memberships_url(account))
  end

  it "update the membership" do
    edited_membership.should have_received(:update_attributes!).with(attributes)
  end

  it "sets a flash message" do
    should set_the_flash.to(/update/i)
  end
end

describe MembershipsController, "destroy", :as => :account_admin do
  let(:removed_membership) { Factory.stub(:membership, :account => account) }

  before do
    Membership.stubs(:find => removed_membership)
    removed_membership.stubs(:destroy)
    delete :destroy, :id => removed_membership.to_param, :account_id => account.to_param
  end

  it "redirects to the account memberships index" do
    should redirect_to(account_memberships_url(account))
  end

  it "removes the membership" do
    removed_membership.should have_received(:destroy)
  end

  it "sets a flash message" do
    should set_the_flash.to(/remove/i)
  end
end
