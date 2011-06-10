module Saucy
  module Account
    extend ActiveSupport::Concern

    included do
      include Saucy::Subscription

      has_many :memberships, :dependent => :destroy
      has_many :users, :through => :memberships
      has_many :projects, :dependent => :destroy
      has_many :admins, :through    => :memberships,
                        :source     => :user,
                        :conditions => { 'memberships.admin' => true }
      has_many :non_admins, :through    => :memberships,
                            :source     => :user,
                            :conditions => { 'memberships.admin' => false }

      belongs_to :plan

      delegate :free?, :billed?, :trial?, :to => :plan

      validates_uniqueness_of :keyword
      validates_presence_of :name, :keyword, :plan_id

      attr_accessible :name, :keyword

      validates_format_of :keyword,
                          :with    => %r{^[a-z0-9_-]+$},
                          :message => "must be only lower case letters and underscores."

      before_create :set_trial_expiration
    end

    module InstanceMethods
      def to_param
        keyword
      end

      def has_member?(user)
        memberships.exists?(:user_id => user.id)
      end

      def users_by_name
        users.by_name
      end

      def projects_by_name
        projects.by_name
      end

      def projects_visible_to(user)
        projects.visible_to(user)
      end

      def memberships_by_name
        memberships.by_name
      end

      def expired?
        trial? && past_trial?
      end

      def past_trial?
        trial_expires_at && trial_expires_at < Time.now
      end

      def admin_emails
        admins.map(&:email)
      end

      def set_trial_expiration
        self.trial_expires_at = 30.days.from_now(created_at || Time.now)
      end

      def users_count
        users.count
      end

      def projects_count
        projects.active.count
      end
    end

    module ClassMethods
      def deliver_new_unactivated_notifications
        new_unactivated.each do |account|
          BillingMailer.new_unactivated(account).deliver
          account.asked_to_activate = true
          account.save!
        end
      end

      def deliver_expiring_trial_notifications
        trial_expiring.each do |account|
          BillingMailer.expiring_trial(account).deliver
          account.notified_of_expiration = true
          account.save!
        end
      end

      def deliver_completed_trial_notifications
        trial_completed.each do |account|
          BillingMailer.completed_trial(account).deliver
          account.notified_of_completed_trial = true
          account.save!
        end
      end

      def trial_expiring
        trial.
          where(:notified_of_expiration => false).
          where(["accounts.trial_expires_at <= ?", 7.days.from_now])
      end

      def new_unactivated
        where(["accounts.created_at <= ?", 7.days.ago]).
          where(:asked_to_activate => false, :activated => false)
      end

      def trial_completed
        trial.
          where(:notified_of_completed_trial => false).
          where(["accounts.trial_expires_at <= ?", Time.now])
      end

      def trial
        includes(:plan).
          where(:plans => { :trial => true })
      end
    end
  end
end
