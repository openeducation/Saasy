class PlansController < ApplicationController
  layout Saucy::Layouts.to_proc

  def index
    @plans = Plan.ordered
  end

  def edit
    @plans = Plan.ordered
    @account = current_account
  end

  def update
    @plans = Plan.ordered
    @account = current_account
    Saucy::Configuration.notify("plan_upgraded", :account => @account,
                                                 :request => request)
    if @account.save_customer_and_subscription!(params[:account])
      redirect_to edit_account_path(@account), :notice => t('.update.notice', :default => "Plan changed successfully")
    else
      render :edit
    end
  end
end
