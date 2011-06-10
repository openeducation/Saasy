module Saucy
  module User
    extend ActiveSupport::Concern

    included do
      attr_accessible :name, :project_ids, :email, :password
      has_many :memberships
      has_many :accounts, :through => :memberships
      has_many :permissions
      has_many :projects, :through => :permissions
      validates_presence_of :name
    end

    module InstanceMethods
      def admin_of?(account)
        memberships.exists?(:account_id => account.id, :admin => true)
      end

      def member_of?(account_or_project)
        account_or_project.has_member?(self)
      end
    end

    module ClassMethods
      def by_name
        order('users.name')
      end
    end
  end
end
