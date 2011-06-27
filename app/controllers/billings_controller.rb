class BillingsController < ApplicationController
  before_filter :authorize_admin, :except => [:show]
  layout Saucy::Layouts.to_proc

  def show
  end

  def edit
    @account = current_account
    @account.cardholder_name = @account.credit_card.cardholder_name
    @account.billing_email = @account.customer.email
    @account.expiration_month = @account.credit_card.expiration_month
    @account.expiration_year = @account.credit_card.expiration_year
  end

  def update
    @account = current_account
    if @account.save_customer_and_subscription!(params[:account])
      redirect_to account_billing_path(@account), :notice => t('.update.notice', :default => "Billing information updated successfully")
    else
      render :edit
    end
  end
end
