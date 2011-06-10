require 'spec_helper'

describe "/accounts/_account.html.erb" do
  let(:account) { Factory.stub(:account) }
  let(:edit_link) { %{href="#{edit_account_path(account)}"} }
  let(:user) { Factory.stub(:user) }

  before { view.stubs(:current_user => user) }

  def render_account
    render :partial => "accounts/account",
           :locals  => { :account => account, :projects => projects }
  end

  context "with projects" do
    let(:project) { Factory.stub(:project, :name => 'Test Project') }
    let(:projects) { [project] }
    before { render_account }

    it "renders projects" do
      rendered.should include(project.name)
    end

    it "doesn't render the blank slate" do
      rendered.should_not include("blank_slate")
    end
  end

  context "without projects" do
    let(:projects) { [] }
    before { render_account }

    it "renders the blank slate" do
      rendered.should include("blank_slate")
    end
  end
end
