require 'spec_helper'

describe InvitationsController, "routes" do
  it { should route(:get, "/accounts/abc/invitations/new").
                to(:action => :new, :account_id => 'abc') }
  it { should route(:post, "/accounts/abc/invitations").
                to(:action => :create, :account_id => 'abc') }
  it { should route(:get, "/accounts/abc/invitations/xyz").
                to(:action => :show, :account_id => 'abc', :id => 'xyz') }
  it { should route(:put, "/accounts/abc/invitations/xyz").
                to(:action => :update, :account_id => 'abc', :id => 'xyz') }
end

describe InvitationsController, "permissions" do
  let(:account) { Factory(:account) }
  before { sign_in }
  it { should deny_access.
                on(:get, :new, :account_id => account.to_param).
                flash(/admin/) }
  it { should deny_access.
                on(:post, :create, :account_id => account.to_param).
                flash(/admin/) }
end

describe InvitationsController, "new", :as => :account_admin do
  let(:invitation) { Invitation.new }
  let(:projects) { ['one', 'two'] }

  before do
    Account.stubs(:find_by_keyword! => account)
    account.stubs(:projects_by_name => projects)
    Invitation.stubs(:new => invitation)
    get :new, :account_id => account.to_param
  end

  it "renders the new template" do
    should respond_with(:success)
    should render_template(:new)
  end

  it "assigns an invitation" do
    Invitation.should have_received(:new)
    should assign_to(:invitation).with(invitation)
  end

  it "assigns projects" do
    should assign_to(:projects).with(projects)
  end
end

describe InvitationsController, "valid create", :as => :account_admin do
  let(:invitation) { Factory.stub(:invitation) }
  let(:attributes) { 'attributes' }

  before do
    Invitation.stubs(:new => invitation)
    invitation.stubs(:account=)
    invitation.stubs(:sender=)
    invitation.stubs(:save => true)
    post :create, :account_id => account.to_param, :invitation => attributes
  end

  it "redirects to the membership index" do
    should redirect_to(account_memberships_url(account))
  end

  it "saves an invitation" do
    Invitation.should have_received(:new).with(attributes)
    invitation.should have_received(:account=).with(account)
    invitation.should have_received(:sender=).with(current_user)
    invitation.should have_received(:save)
  end

  it "sets a flash message" do
    should set_the_flash.to(/invited/i)
  end
end

describe InvitationsController, "invalid create", :as => :account_admin do
  let(:invitation) { Factory.stub(:invitation) }
  let(:projects) { ['one', 'two'] }

  before do
    Invitation.stubs(:new => invitation)
    invitation.stubs(:save => false)
    Account.stubs(:find_by_keyword! => account)
    account.stubs(:projects_by_name => projects)
    post :create, :account_id => account.to_param, :invitation => {}
  end

  it "renders the new template" do
    should respond_with(:success)
    should render_template(:new)
  end

  it "doesn't set a flash message" do
    should_not set_the_flash
  end

  it "assigns projects" do
    should assign_to(:projects).with(projects)
  end
end

describe InvitationsController, "show" do
  let(:invitation) { Factory.stub(:invitation, :code => 'abc') }
  let(:account)    { invitation.account }

  before do
    Invitation.stubs(:find_by_code! => invitation)
    get :show, :id => invitation.to_param, :account_id => account.to_param
  end

  it "renders the show template" do
    should respond_with(:success)
    should render_template(:show)
  end

  it "assigns the invitation" do
    Invitation.should have_received(:find_by_code!).with(invitation.to_param)
    should assign_to(:invitation).with(invitation)
  end
end

describe InvitationsController, "show for a used invitation" do
  let(:invitation) { Factory.stub(:invitation, :code => 'abc', :used => true) }
  let(:account)    { invitation.account }

  before do
    Invitation.stubs(:find_by_code! => invitation)
    get :show, :id => invitation.to_param, :account_id => account.to_param
  end

  it "redirects to the root url" do
    should redirect_to("/")
  end

  it "sets a flash message" do
    should set_the_flash.to(/used/i)
  end
end

describe InvitationsController, "valid update" do
  let(:invitation) { Factory.stub(:invitation, :code => 'abc') }
  let(:account)    { invitation.account }
  let(:attributes) { 'attributes' }
  let(:user)       { Factory.stub(:user) }

  before do
    Invitation.stubs(:find_by_code! => invitation)
    invitation.stubs(:accept => true)
    invitation.stubs(:user   => user)
    put :update, :id         => invitation.to_param,
                 :account_id => account.to_param,
                 :invitation => attributes
  end

  it "signs the user in" do
    should be_signed_in.as(user)
  end

  it "accepts the invitation" do
    Invitation.should have_received(:find_by_code!).with(invitation.to_param)
    invitation.should have_received(:accept).with(attributes)
  end

  it "redirects to the root page" do
    should redirect_to(root_url)
  end
end

describe InvitationsController, "invalid update" do
  let(:invitation) { Factory.stub(:invitation, :code => 'abc') }
  let(:account) { invitation.account }

  before do
    Invitation.stubs(:find_by_code! => invitation)
    invitation.stubs(:accept => false)
    put :update, :id         => invitation.to_param,
                 :account_id => account.to_param,
                 :invitation => {}
  end

  it "doesn't sign in" do
    should_not be_signed_in
  end

  it "renders the show template" do
    should respond_with(:success)
    should render_template(:show)
  end

  it "assigns the invitation" do
    should assign_to(:invitation).with(invitation)
  end
end

describe InvitationsController, "update for a used invitation" do
  let(:invitation) { Factory.stub(:invitation, :code => 'abc', :used => true) }
  let(:account)    { invitation.account }

  before do
    Invitation.stubs(:find_by_code! => invitation)
    put :update, :id => invitation.to_param, :account_id => account.to_param
  end

  it "redirects to the root url" do
    should redirect_to("/")
  end

  it "sets a flash message" do
    should set_the_flash.to(/used/i)
  end
end

