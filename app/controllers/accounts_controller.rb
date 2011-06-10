class AccountsController < ApplicationController
  before_filter :authorize, :only => [:index, :edit, :update]
  before_filter :authorize_admin, :except => [:new, :create, :index]
  before_filter :ensure_active_account, :only => [:edit, :update]
  layout Saucy::Layouts.to_proc

  def new
    @plan = Plan.find(params[:plan_id])
    @signup = Signup.new
    Saucy::Configuration.notify("plan_viewed", :request => request,
                                               :plan    => @plan)
  end

  def create
    @plan = Plan.find(params[:plan_id])
    @signup = Signup.new(params[:signup])
    @signup.user = current_user
    @signup.plan = @plan
    if @signup.save
      Saucy::Configuration.notify("account_created", :request => request,
                                                     :account => @signup.account)
      flash[:success] = "Account was created."
      sign_in @signup.user
      redirect_to new_account_project_path(@signup.account)
    else
      render :action => 'new'
    end
  end

  def index
    if current_user.projects.size == 1
      flash.keep
      redirect_to project_path(current_user.projects.first)
    else
      @accounts = current_user.accounts
    end
  end

  def edit
    @account = current_account
  end

  def update
    @account = current_account
    if @account.update_attributes(params[:account])
      flash[:success] = 'Account was updated.'
      redirect_to edit_profile_url
    else
      render :action => :edit
    end
  end

  def destroy
    current_account.destroy
    flash[:success] = "Your account has been deleted."
    redirect_to root_url
  end

  private

  def current_account
    Account.find_by_keyword!(params[:id])
  end

  def current_account?
    params[:id].present?
  end
end
