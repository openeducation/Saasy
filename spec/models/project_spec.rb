require 'spec_helper'

describe Project do
  it { should belong_to(:account) }
  it { should validate_presence_of(:account_id) }
  it { should have_many(:permissions) }
  it { should validate_presence_of(:keyword) }
  it { should validate_presence_of(:name) }

  it { should allow_value("hello").for(:keyword) }
  it { should allow_value("0123").for(:keyword) }
  it { should allow_value("hello_world").for(:keyword) }
  it { should allow_value("hello-world").for(:keyword) }
  it { should_not allow_value("HELLO").for(:keyword) }
  it { should_not allow_value("hello world").for(:keyword) }

  it { should_not allow_mass_assignment_of(:account_id) }
  it { should_not allow_mass_assignment_of(:account) }

  it "finds projects visible to a user" do
    account = Factory(:account)
    user = Factory(:user)
    membership = Factory(:membership, :user => user, :account => account)
    visible_projects = [Factory(:project, :account => account),
                        Factory(:project, :account => account)]
    invisible_project = Factory(:project, :account => account)
    visible_projects.each do |visible_project|
      Factory(:permission, :project            => visible_project,
                                   :membership => membership)
    end

    Project.visible_to(user).to_a.should =~ visible_projects
  end

  it "returns projects by name" do
    Factory(:project, :name => "def")
    Factory(:project, :name => "abc")
    Factory(:project, :name => "ghi")

    Project.by_name.map(&:name).should == %w(abc def ghi)
  end

  context "archived and non-archived projects" do
    before do
      @archived = [Factory(:project, :archived => true), Factory(:project, :archived => true)]
      @active = [Factory(:project, :archived => false)]
    end

    it "returns only archived projects with archived" do
      Project.archived.all.should == @archived
    end

    it "returns only active projects with active" do
      Project.active.all.should == @active
    end
  end

  context "archived project for an account at its project limit" do
    before do
      @archived = Factory(:project, :archived => true)
      @account = @archived.account
      Limit.stubs(:can_add_one?).with("projects", @account).returns(false)
    end

    it "cannot be unarchived" do
      @archived.archived = false
      @archived.save.should_not be
      @archived.errors[:archived].first.should match(/at your limit/)
    end
  end

  context "project moving to an account at its project limit" do
    before do
      @project = Factory(:project)
      @account = Factory(:account)
      Limit.stubs(:can_add_one?).with("projects", @account).returns(false)
    end

    it "cannot be moved" do
      @project.account = @account
      @project.save.should_not be
      @project.errors[:account_id].first.should match(/at your limit/)
    end
  end

  it "should give its keyword for to_param" do
    project = Factory(:project)
    project.to_param.should == project.keyword
  end
end

describe Project, "keyword uniqueness" do
  let(:project) { Factory(:project) }
  subject do
    Factory.build(:project, :account => project.account)
  end

  it "validates uniqueness of it's keyword" do
    subject.keyword = project.keyword
    subject.save
    subject.errors[:keyword].should include("has already been taken")
  end
end

share_examples_for "default project permissions" do
  it "is viewable by admins by default" do
    admins.each do |admin|
      subject.users.should include(admin)
    end
  end

  it "isn't viewable by non-members" do
    subject.users.should_not include(non_admin)
    subject.users.should_not include(non_member)
  end
end

describe Project, "for an account with admin and non-admin users" do
  let!(:account)       { Factory(:account, :name => "Account") }
  let!(:other_account) { Factory(:account, :name => "Other") }
  let!(:non_admin)     { Factory(:user) }
  let!(:admins)        { [Factory(:user), Factory(:user)] }
  let!(:non_member)    { Factory(:user) }
  subject              { Factory.build(:project, :account => account) }

  before do
    Factory(:membership, :account => account, :user => non_admin, :admin => false)
    Factory(:membership, :account => other_account,
                                 :user    => non_member,
                                 :admin   => true)
    admins.each do |admin|
      Factory(:membership, :user => admin, :account => account, :admin => true)
    end

    subject.assign_default_permissions 
  end

  context "before saving" do
    it_behaves_like "default project permissions"
  end

  context "after saving" do
    before do
      subject.save!
      subject.reload
    end

    it_behaves_like "default project permissions"
  end
end

describe Project, "saved" do
  subject { Factory(:project) }

  it "has a member with a membership" do
    user = Factory(:user)
    membership = Factory(:membership, :account => subject.account,
                                                      :user    => user)
    membership = Factory(:permission, :project            => subject,
                                              :membership => membership)
    should have_member(user)
  end

  it "doesn't have a member without a membership" do
    user = Factory(:user)
    should_not have_member(user)
  end
end

describe Project, "assigning users on update" do
  subject { Factory(:project) }

  let(:account) { subject.account }
  let!(:user_to_remove) { Factory(:user) }
  let!(:user_to_add) { Factory(:user) }
  let!(:admin) { Factory(:user) }

  before do
    membership_to_remove =
      Factory(:membership, :account => account, :user => user_to_remove)
    membership_to_add =
      Factory(:membership, :account => account, :user => user_to_add)
    admin_membership =
      Factory(:membership, :account => account, :user => admin, :admin => true)
    Factory(:permission, :membership => membership_to_remove,
                         :project    => subject)

    subject.reload.update_attributes!(:user_ids => [user_to_add.id, ""])
  end

  it "adds an added user" do
    user_to_add.should be_member_of(subject)
  end

  it "removes a removed user" do
    user_to_remove.should_not be_member_of(subject)
  end

  it "keeps an admin" do
    admin.should be_member_of(subject)
  end
end

describe Project, "assigning users on create" do
  subject       { Factory.build(:project) }
  let(:account) { subject.account }
  let!(:member) { Factory(:user) }
  let!(:admin)  { Factory(:user) }

  before do
    Factory(:membership, :account => account, :user => member)
    Factory(:membership, :account => account, :user => admin, :admin => true)
    subject.save
  end

  it "adds admins to the project" do
    admin.should be_member_of(subject)
  end

  it "ignores normal users" do
    member.should_not be_member_of(subject)
  end
end
