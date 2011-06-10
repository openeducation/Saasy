module Saucy
  module Project
    extend ActiveSupport::Concern

    included do
      belongs_to :account
      has_many :permissions, :dependent => :destroy
      has_many :users, :through => :permissions

      validates_presence_of :account_id, :keyword, :name

      validates_uniqueness_of :keyword, :scope => :account_id

      validates_format_of :keyword,
                          :with    => %r{^[a-z0-9_-]+$},
                          :message => "must be only lower case letters or underscores."


      validate :ensure_account_within_limit, :on => :update

      after_create :setup_memberships
      after_update :update_memberships

      attr_protected :account, :account_id

      # We have to define these here instead of mixing them in,
      # because ActiveRecord does the same.

      def user_ids=(new_user_ids)
        @new_user_ids = new_user_ids.reject { |user_id| user_id.blank? }
      end

      def users
        if new_record?
          permissions.map { |permission| permission.membership.user }
        else
          permissions.includes(:user).map { |permission| permission.user }
        end
      end

      def user_ids
        users.map(&:id)
      end
    end

    module ClassMethods
      def visible_to(user)
        where(['projects.id IN(?)', user.project_ids])
      end

      def archived
        where(:archived => true)
      end

      def active
        where(:archived => false)
      end

      def by_name
        order("projects.name")
      end

      def build_with_default_permissions
        new.assign_default_permissions
      end
    end

    module InstanceMethods
      def to_param
        keyword
      end

      def has_member?(user)
        permissions.
          joins(:membership).
          exists?(:memberships => { :user_id => user.id })
      end

      def assign_default_permissions
        account.memberships.where(:admin => true).each do |membership|
          self.permissions.build(:membership => membership)
        end
        self
      end

      private

      def setup_memberships
        @new_user_ids ||= []
        @new_user_ids += admin_user_ids
        removed_user_ids = self.user_ids - @new_user_ids
        added_user_ids = @new_user_ids - self.user_ids

        permissions.where(:user_id => removed_user_ids).destroy_all
        added_user_ids.each do |added_user_id|
          membership =
            account.memberships.where(:user_id => added_user_id).first
          permissions.create!(:membership => membership)
        end
      end

      def update_memberships
        setup_memberships if @new_user_ids
      end

      def admin_user_ids
        account.
          memberships.
          where(:admin => true).
          select(:user_id).
          map(&:user_id)
      end

      def ensure_account_within_limit
        message = "You are at your limit of %{name} for your current plan."
        if archived_changed? && !archived? && !Limit.can_add_one?("projects", account)
          errors.add(:archived, I18n.t("saucy.errors.limited", :default => message, :name => 'projects'))
        end
        if account_id_changed? && !Limit.can_add_one?("projects", account)
          errors.add(:account_id, I18n.t("saucy.errors.limited", :default => message, :name => 'projects'))
        end
      end
    end
  end
end
