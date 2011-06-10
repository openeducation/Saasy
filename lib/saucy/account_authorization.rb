module Saucy
  module AccountAuthorization
    extend ActiveSupport::Concern

    included do
      helper_method :current_account, :current_project, :current_account?, :current_project?
      include InstanceMethods
    end

    module InstanceMethods
      protected

      def current_account
        ::Account.find_by_keyword!(params[:account_id])
      end

      def current_project
        current_account.projects.find_by_keyword!(params[:project_id])
      end

      def current_project?
        params[:project_id].present?
      end

      def current_account?
        params[:account_id].present?
      end

      def authorize_admin
        unless current_user.admin_of?(current_account)
          deny_access("You must be an admin to access that page.")
        end
      end

      def authorize_member
        unless current_user.member_of?(current_project)
          deny_access("You do not have permission for this project.")
        end
      end

      def ensure_active_account
        if current_account?
          if current_account.past_due?
            redirect_unusable_account account_billing_path(current_account),
                                      "past_due"
          end
          if current_account.expired?
            redirect_unusable_account edit_account_plan_path(current_account),
                                      "expired"
          end
        end
      end

      def redirect_unusable_account(path, failure)
        role = current_user.admin_of?(current_account) ? 'admin' : 'user'
        flash[:alert] = t("saucy.errors.#{failure}.#{role}")
        redirect_to path
      end

      def ensure_account_within_limit(limit_name)
        if !Limit.can_add_one?(limit_name, current_account)
          redirect_to :back, :alert => t("saucy.errors.limited", :default => "You are at your limit of %{name} for your current plan.", :name => limit_name)
        end
      end
    end
  end
end
