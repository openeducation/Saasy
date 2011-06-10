module Saucy
  module Plan
    extend ActiveSupport::Concern

    included do
      has_many :accounts
      has_many :limits

      validates_presence_of :name

      def self.ordered
        order('price desc')
      end

      def self.paid_by_price
        paid.ordered
      end

      def self.trial
        free.first
      end

      def self.paid
        where('price > 0')
      end

      def self.free
        where('price = 0')
      end
    end

    module InstanceMethods
      def free?
        price.zero?
      end

      def billed?
        !free?
      end

      def can_add_more?(limit, amount)
        limits.numbered.named(limit).value > amount
      end

      def allows?(limit)
        limits.boolean.named(limit).allowed?
      end

      def limit(limit_name)
        limits.named(limit_name)
      end
    end
  end
end
