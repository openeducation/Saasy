require 'spec_helper'

describe ProjectsController, "routes" do
  it { should route(:get, "/accounts/abc/projects/new").
                to(:action => :new, :account_id => 'abc') }
  it { should route(:post, "/accounts/abc/projects").
                to(:action => :create, :account_id => 'abc') }
  it { should route(:get, "/accounts/abc/projects/def/edit").
                to(:action => :edit, :account_id => 'abc', :id => 'def') }
  it { should route(:put, "/accounts/abc/projects/def").
                to(:action => :update, :account_id => 'abc', :id => 'def') }
  it { should route(:delete, "/accounts/abc/projects/def").
                to(:action => :destroy, :account_id => 'abc', :id => 'def') }
  it { should route(:get, "/accounts/abc/projects").
                to(:action => :index, :account_id => 'abc') }
end

describe ProjectsController, "new", :as => :account_admin do
  before do
    get :new, :account_id => account.to_param
  end

  it { should respond_with(:success) }
  it { should render_template(:new) }
  it { should_not set_the_flash }
  it { should assign_to( :project) }

  it "has a new project that belongs to account" do
    assigns(:project).account.should == account
  end
end

describe ProjectsController, "#show as another user" do
  let(:account) { Factory(:account) }
  let(:user)    { Factory(:user) }
  let(:project) { Factory(:project, :account => account) }
  before do
    sign_in_as(user)
    get :show, :account_id => account.to_param, :id => project.to_param
  end

  it { should respond_with(:redirect) }
  it { should set_the_flash.to(/do not have permission/) }
end

describe ProjectsController, "create", :as => :account_admin do
  before do
    @project_count = Project.count
    post :create,
         :project    => Factory.attributes_for(:project),
         :account_id => account.to_param
  end

  it "should change Project count by 1" do
    Project.count.should == @project_count + 1
  end

  it "should place the new project into the account" do
    Project.last.account.should == account
  end

  it "should redirect to the edit page" do
    should redirect_to(controller.project_url(assigns(:project)))
  end
end

describe ProjectsController, "edit", :as => :project_admin do
  before do
    get :edit, :id => project.to_param, :account_id => account.to_param
  end

  it { should respond_with(:success) }
  it { should render_template(:edit) }
  it { should_not set_the_flash }
  it { should assign_to(:project) }
end

describe ProjectsController, "update", :as => :project_admin do
  before do
    put :update, :project    => Factory.attributes_for(:project),
                 :id         => project.to_param,
                 :account_id => account.to_param
  end

  it "should redirect to account_projects_url" do
    should redirect_to(account_projects_url(account))
  end
end

describe ProjectsController, "update with account that you don't have access to", :as => :project_admin do
  before do
    put :update, :project    => Factory.attributes_for(:project, :account_id => Factory(:account).id),
                 :id         => project.to_param,
                 :account_id => account.to_param
  end

  it "should show an error" do
    should set_the_flash.to(/permission/i)
  end

  it "should redirect to account_projects_url" do
    should redirect_to(account_projects_url(account))
  end
end

describe ProjectsController, "create with account that you don't have access to", :as => :account_admin do
  before do
    post :create,
         :project    => Factory.attributes_for(:project, :account_id => Factory(:account).id),
         :account_id => account.to_param
  end

  it "should show an error" do
    should set_the_flash.to(/permission/i)
  end

  it "should redirect to account_projects_url" do
    should redirect_to(account_projects_url(account))
  end
end

describe ProjectsController, "edit with account that you don't have access to", :as => :project_admin do
  before do
    get :edit, :id => project.to_param, :account_id => account.to_param, :project => { :account_id => Factory(:account).id }
  end

  it "should show an error" do
    should set_the_flash.to(/permission/i)
  end

  it "should redirect to account_projects_url" do
    should redirect_to(account_projects_url(account))
  end
end

describe ProjectsController, "edit with account that you have access to", :as => :project_admin do
  before do
    @other_account = Factory(:account)
    Factory(:membership, :user => current_user, :account => @other_account, :admin => true)
    get :edit, :id => project.to_param, :account_id => account.to_param, :project => { :account_id => @other_account.id }
  end

  it { should assign_to(:project) }

  it "sets the new account on the project" do
    assigns(:project).account.should == @other_account
  end
end

describe ProjectsController, "destroy", :as => :project_admin do
  before do
    delete :destroy, :id => project.to_param, :account_id => account.to_param
  end

  it { should set_the_flash.to(/deleted/) }
  it { should assign_to(:project) }

  it "should redirect to account_projects_url" do
    should redirect_to(account_projects_url(account))
  end
end

describe ProjectsController, "index", :as => :account_admin do
  let(:projects) { ['one', 'two'] }

  before do
    projects.stubs(:archived => projects, :active => projects)
    Account.stubs(:find_by_keyword! => account)
    account.stubs(:projects => projects)
    get :index, :account_id => account.to_param
  end

  it "renders the index template" do
    should respond_with(:success)
    should render_template(:index)
  end

  it "assigns projects" do
    account.should have_received(:projects).times(2)
    should assign_to(:active_projects).with(projects)
    should assign_to(:archived_projects).with(projects)
  end
end

describe ProjectsController, "as a non-admin", :as => :project_member do
  it { should deny_access.on(:get, :edit, :id         => project.to_param,
                                          :account_id => account.to_param).
                          flash(/admin/) }

  it { should deny_access.on(:put, :update, :id         => project.to_param,
                                            :account_id => account.to_param).
                          flash(/admin/) }

  it { should deny_access.on(:delete, :destroy, :id         => project.to_param,
                                                :account_id => account.to_param).
                          flash(/admin/) }

  it { should deny_access.on(:get, :new, :account_id => account.to_param).flash(/admin/) }

  it { should deny_access.on(:post, :create, :account_id => account.to_param).
                          flash(/admin/) }
end

describe ProjectsController, "show for a duplicate project keyword", :as => :project_admin do
  before do
    Factory(:project, :keyword => "test")

    account = Factory(:account)
    project = Factory(:project, :account => account, :keyword => "test")
    sign_in_as_non_admin_of_project(project)
    get :show, :id => "test", :account_id => account.to_param
  end

  it { should respond_with(:success) }
  it { should_not set_the_flash }
end
