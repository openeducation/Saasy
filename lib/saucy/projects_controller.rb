module Saucy
  module ProjectsController
    extend ActiveSupport::Concern

    included do
      helper_method :current_project?
      before_filter :authorize
      before_filter :authorize_member,      :only   => :show
      before_filter :authorize_admin,       :except => [:show]
      before_filter :ensure_active_account, :only   => [:show, :destroy, :index]
      before_filter :ensure_account_within_projects_limit, :only => [:new, :create]
      before_filter :ensure_admin_for_project_account, :only => [:edit, :create, :update]
      layout Saucy::Layouts.to_proc
    end

    module InstanceMethods
      def new
        @project = current_account.projects.build_with_default_permissions
        if @project.keyword.blank?
          @project.keyword = 'keyword'
        end
      end

      def create
        @project = current_account.projects.build(params[:project])
        if @project.save
          flash[:notice] = "Project successfully created"
          redirect_to project_url(@project)
        else
          render :action => :new
        end
      end

      def edit
        @project = current_project
        set_project_account_if_moving
      end

      def update
        @project = current_project
        set_project_account_if_moving
        if @project.update_attributes params[:project]
          flash[:success] = 'Project was updated.'
          redirect_to account_projects_url(@project.account)
        else
          render :action => :edit
        end
      end

      def show
        current_project
      end

      def destroy
        current_project.destroy
        flash[:success] = "Project has been deleted"
        redirect_to account_projects_url(current_project.account)
      end

      def index
        @active_projects = current_account.projects.active
        @archived_projects = current_account.projects.archived
      end

      private

      def set_project_account_if_moving
        if params[:project] && params[:project][:account_id]
          @project.account_id = params[:project][:account_id]
        end
      end

      def current_project
        @project ||= current_account.projects.find_by_keyword!(params[:id])
      end

      def current_project?
        params[:id].present?
      end

      def ensure_account_within_projects_limit
        ensure_account_within_limit("projects")
      end

      def ensure_admin_for_project_account
        if params[:project] && params[:project][:account_id]
          if !current_user.admin_of?(::Account.find(params[:project][:account_id]))
            redirect_to account_projects_url(current_account), :alert => t('account.permission_denied', :default => "You do not have permission to this account.")
          end
        end
      end
    end
  end
end
