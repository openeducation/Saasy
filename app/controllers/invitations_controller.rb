class InvitationsController < ApplicationController
  before_filter :authorize_admin, :except => [:show, :update]
  before_filter :ensure_account_within_users_limit, :only => [:new, :create]
  skip_before_filter :authorize, :only => [:show, :update]
  layout Saucy::Layouts.to_proc

  def new
    assign_projects
    @invitation = Invitation.new
    render
  end

  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.account = current_account
    @invitation.sender  = current_user
    if @invitation.save
      flash[:success] = "User invited."
      redirect_to account_memberships_url(current_account)
    else
      assign_projects
      render :action => 'new'
    end
  end

  def show
    with_invitation { render }
  end

  def update
    with_invitation do
      if @invitation.accept(params[:invitation])
        sign_in @invitation.user
        redirect_to root_url
      else
        render :action => 'show'
      end
    end
  end

  private

  def assign_projects
    @projects = current_account.projects_by_name
  end

  def with_invitation
    @invitation = Invitation.find_by_code!(params[:id])
    if @invitation.used?
      flash[:error] = t("invitations.show.used",
                        :default => "That invitation has already been used.")
      redirect_to root_url
    elsif signed_in? && current_user.email == @invitation.email
      if @invitation.accept({:existing_user => current_user})
        redirect_to root_url
      end
    else
      yield
    end
  end

  def ensure_account_within_users_limit
    ensure_account_within_limit("users")
  end
end
