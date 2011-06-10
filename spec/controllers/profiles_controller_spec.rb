require 'spec_helper'

describe ProfilesController, "routes" do
  it { should route(:get, "/profile/edit").to(:action => :edit) }
  it { should route(:put, "/profile").to(:action => :update) }
end

describe ProfilesController, "signed out" do
  it { should deny_access.on(:get, :edit) }
  it { should deny_access.on(:put, :update) }
end

describe ProfilesController, "edit", :as => :user do
  before { get :edit }
  it { should respond_with(:success) }
  it { should assign_to(:user).with(user) }
end

describe ProfilesController, "valid update", :as => :user do
  let(:attributes) { 'attributes' }

  before do
    user.stubs(:update_attributes => true)
    put :update, :user => attributes
  end

  it { should set_the_flash.to(/has been updated/) }

  it "redirects to the user" do
    should redirect_to(edit_profile_url)
  end

  it "updates the user" do
    user.should have_received(:update_attributes).with(attributes)
  end
end

describe ProfilesController, "invalid update", :as => :user do
  before do
    user.stubs(:update_attributes => false)
    get :update, :user => { :email => "" }
  end

  it { should_not set_the_flash }
  it { should render_template(:edit) }
  it { should assign_to(:user).with(user) }
end

