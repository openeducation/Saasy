require 'spec_helper'

describe AccountsController, "routes" do
  it { should route(:get, "/plans/abc/accounts/new").
                to(:action => :new, :plan_id => :abc) }
  it { should route(:get, "/accounts").to(:action => :index) }
  it { should route(:post, "/plans/abc/accounts").
                to(:action => :create, :plan_id => :abc) }
  it { should route(:put, "/accounts/1").to(:action => :update, :id => 1) }
  it { should route(:get, "/accounts/1/edit").to(:action => :edit, :id => 1) }
  it { should route(:delete, "/accounts/1").to(:action => :destroy, :id => 1) }
end

describe AccountsController, "new" do
  let(:signup) { stub('signup') }
  let(:plan) { Factory(:plan) }

  before do
    Signup.stubs(:new => signup)
    get :new, :plan_id => plan.to_param
  end

  it "renders the new account form" do
    should respond_with(:success)
    should render_template(:new)
  end

  it "assigns a new signup" do
    Signup.should have_received(:new)
    should assign_to(:signup).with(signup)
  end

  it "notifies observers" do
    should notify_observers("plan_viewed", :plan => plan, :request => request)
  end
end

describe AccountsController, "successful create for a confirmed user" do
  let(:user) { Factory.stub(:user) }
  let(:account) { Factory.stub(:account) }
  let(:signup) { stub('signup', :user    => user,
                                :user=   => nil,
                                :plan=   => plan,
                                :account => account) }
  let(:signup_attributes) { "attributes" }
  let(:plan) { Factory(:plan) }

  before do
    Signup.stubs(:new => signup)
    signup.stubs(:save => true)
    sign_in_as user
    post :create, :signup => signup_attributes, :plan_id => plan.to_param
  end

  it "creates an signup" do
    Signup.should have_received(:new).with(signup_attributes)
    signup.should have_received(:save)
  end

  it "redirects to the root" do
    should redirect_to(new_account_project_url(signup.account))
  end

  it "sets the current user" do
    signup.should have_received(:user=).with(user)
  end

  it { should set_the_flash.to(/created/i) }
  it { should_not set_the_flash.to(/confirm/i) }
  it { should be_signed_in.as(user) }

  it "notifies observers" do
    should notify_observers("account_created", :account => signup.account,
                                               :request => request)
  end
end

describe AccountsController, "failed create" do
  let(:signup) { stub('signup', :user= => nil, :plan= => plan) }
  let(:signup_attributes) { "attributes" }
  let(:plan) { Factory(:plan) }

  before do
    Signup.stubs(:new => signup)
    signup.stubs(:save => false)
    post :create, :signup => signup_attributes, :plan_id => plan.to_param
  end

  it "creates an signup" do
    Signup.should have_received(:new).with(signup_attributes)
    signup.should have_received(:save)
  end

  it "renders the new signup form" do
    should respond_with(:success)
    should render_template(:new)
  end

  it "assigns a new signup" do
    Signup.should have_received(:new)
    should assign_to(:signup).with(signup)
  end
end

describe AccountsController, "index with multiple projects" do
  let(:user) { Factory.stub(:user) }
  let(:accounts) { %w(one two) }
  let(:projects) { %w(one two) }

  before do
    user.stubs(:accounts => accounts)
    user.stubs(:projects => projects)
    sign_in_as user
    get :index
  end

  it "renders the dashboard page" do
    should respond_with(:success)
    should render_template(:index)
  end

  it "assigns the user's accounts" do
    user.should have_received(:accounts)
    should assign_to(:accounts).with(accounts)
  end
end

describe AccountsController, "signed out" do
  it "redirects to sign_in on index" do
    get :index
    should redirect_to(sign_in_path)
  end
  it "redirects to sign_in on edit" do
    get :edit, :id => 1
    should redirect_to(sign_in_path)
  end
  it "redirects to sign_in on update" do
    put :update, :id => 1, :account => {}
    should redirect_to(sign_in_path)
  end
end

describe AccountsController, "index with one project" do
  let(:user) { Factory.stub(:user) }
  let(:accounts) { %w(one two) }
  let(:projects) { [Factory.stub(:project)] }

  before do
    user.stubs(:accounts => accounts)
    user.stubs(:projects => projects)
    sign_in_as user
    get :index
  end

  it "redirects to the project" do
    should redirect_to(controller.project_url(projects.first))
  end
end

describe AccountsController, "valid update", :as => :account_admin do
  before do
    put :update,
        :account => Factory.attributes_for(:account),
        :id => account.to_param
  end

  it "redirects to settings" do
    should redirect_to(edit_profile_url)
  end

  it { should set_the_flash.to(/updated/) }
end

describe AccountsController, "invalid update", :as => :account_admin do
  before do
    put :update,
        :account => {:name => ""},
        :id => account.to_param
  end

  it { should respond_with(:success) }
  it { should render_template(:edit) }
end

describe AccountsController, "edit", :as => :account_admin do
  before do
    get :edit, :id => account.to_param
  end

  it "renders the edit template" do
    should respond_with(:success)
    should render_template(:edit)
  end

  it "assigns the account" do
    should assign_to(:account).with(account)
  end
end

describe AccountsController, "destroy", :as => :account_admin do
  before do
    Account.stubs(:find_by_keyword! => account)
    account.stubs(:destroy)
    delete :destroy, :id => account.to_param
  end

  it "redirects to the root url" do
    should redirect_to("/")
  end

  it "sets the flash" do
    should set_the_flash.to(/deleted/i)
  end

  it "deletes the account" do
    account.should have_received(:destroy)
  end
end

describe AccountsController, "permissions", :as => :account_member do
  it { should deny_access.
                on(:get, :edit, :id => account.to_param).
                flash(/admin/) }
  it { should deny_access.
                on(:put, :update, :id => account.to_param).
                flash(/admin/) }
end

