class ProfilesController < ApplicationController
  layout Saucy::Layouts.to_proc

  before_filter :authorize

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your user account has been updated."
      redirect_to edit_profile_url
    else
      render :action => :edit
    end
  end
end
