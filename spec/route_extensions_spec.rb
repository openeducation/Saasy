require 'spec_helper'

describe "Saucy routing extensions" do
  include ActionDispatch::Routing::UrlFor

  let(:_routes) { ActionDispatch::Routing::RouteSet.new }

  before do
    _routes.draw do
      resources :accounts
      through :accounts do
        resources :projects
        through :projects do
          resources :discussions
        end
      end
    end

    extend(_routes.named_routes.module)
  end

  it "allows a nested member path to be accessed through just the child's name" do
    account = stub('account', :to_param => 'abc')
    project = stub('project', :account => account, :to_param => 'def')
    project_path(project).should == "/accounts/abc/projects/def"
  end

  it "allows a nested member url to be accessed through just the child's name" do
    account = stub('account', :to_param => 'abc')
    project = stub('project', :account => account, :to_param => 'def')
    project_url(project, :host => 'example.com').
      should == "http://example.com/accounts/abc/projects/def"
  end

  it "allows a nested collection path to be accessed through just the parent's name" do
    account = stub('account', :to_param => 'abc')
    projects_path(account).should == "/accounts/abc/projects"
  end

  it "allows a nested new path to be accessed through just the parent's name" do
    account = stub('account', :to_param => 'abc')
    new_project_path(account).should == "/accounts/abc/projects/new"
  end

  it "allows a doubly nested member path to be access through just the child's name" do
    account = stub('account', :to_param => 'abc')
    project = stub('project', :account => account, :to_param => 'def')
    discussion = stub('discussion', :project => project, :to_param => 'ghi')
    discussion_path(discussion).should == "/accounts/abc/projects/def/discussions/ghi"
  end
end
