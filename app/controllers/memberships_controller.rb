class MembershipsController < ApplicationController
  before_filter :authorize_admin
  layout Saucy::Layouts.to_proc

  def index
    @memberships = current_account.memberships_by_name
    render
  end

  def edit
    find_membership
    @projects = current_account.projects_by_name
    render
  end

  def update
    find_membership.update_attributes!(params[:membership])
    flash[:success] = "Permissions updated."
    redirect_to account_memberships_url(current_account)
  end

  def destroy
    find_membership.destroy
    flash[:success] = "User removed."
    if @membership.user == current_user
      redirect_to edit_profile_url
    else
      redirect_to account_memberships_url(current_account)
    end
  end

  private

  def find_membership
    @membership ||= Membership.find(params[:id], :include => :account)
  end

  def current_account
    if params[:id]
      find_membership.account
    else
      super
    end
  end
end
