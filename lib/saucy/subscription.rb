module Saucy
  module Subscription
    extend ActiveSupport::Concern

    included do
      require "rubygems"
      require "braintree"

      extend ActiveSupport::Memoizable

      CUSTOMER_ATTRIBUTES = { :cardholder_name => :cardholder_name, 
                              :billing_email => :email, 
                              :card_number => :number, 
                              :expiration_month => :expiration_month, 
                              :expiration_year => :expiration_year, 
                              :verification_code => :cvv }

      attr_accessor *CUSTOMER_ATTRIBUTES.keys

      CUSTOMER_ATTRIBUTES.keys.each do |attribute|
        validates_presence_of attribute, :if => :switching_to_billed?
      end
      before_create :create_customer
      before_create :create_subscription, :if => :billed?
      after_destroy :destroy_customer

      memoize :customer
      memoize :subscription
    end

    module InstanceMethods
      def customer
        Braintree::Customer.find(customer_token) if customer_token
      end

      def credit_card
        customer.credit_cards[0] if customer && customer.credit_cards.any?
      end

      def subscription
        Braintree::Subscription.find(subscription_token) if subscription_token
      end

      def save_customer_and_subscription!(attributes)
        successful = true
        self.plan = ::Plan.find(attributes[:plan_id]) if changing_plan?(attributes)
        if changing_customer_attributes?(attributes)
          successful = update_customer(attributes)
        end
        if successful && past_due?
          successful = retry_subscription_charge!
        end
        if successful && changing_plan?(attributes)
          save_subscription
          flush_cache :subscription
        end
        successful && save
      end

      def can_change_plan_to?(new_plan)
        within_limits_for?(new_plan) && !past_trial_for?(new_plan)
      end

      def past_due?
        subscription_status == Braintree::Subscription::Status::PastDue
      end

      private

      def within_limits_for?(new_plan)
        new_plan.limits.where(:value_type => :number).all? do |limit|
          new_plan.limit(limit.name).value >= send(:"#{limit.name}_count")
        end
      end

      def past_trial_for?(new_plan)
        new_plan.trial? && past_trial?
      end

      def retry_subscription_charge!
        authorized_transaction = Braintree::Subscription.retry_charge(subscription.id).transaction
        result = Braintree::Transaction.submit_for_settlement(authorized_transaction.id)
        handle_errors(authorized_transaction, result.errors) if !result.success?
        update_subscription_cache!
        result.success?
      end

      def update_subscription_cache!
        flush_cache :subscription
        update_attribute(:subscription_status, subscription.status)
        update_attribute(:next_billing_date, subscription.next_billing_date)
      end

      def changing_plan?(attributes)
        attributes[:plan_id].present?
      end

      def changing_customer_attributes?(attributes)
        CUSTOMER_ATTRIBUTES.keys.any? { |attribute| attributes[attribute].present? }
      end

      def set_customer_attributes(attributes)
        CUSTOMER_ATTRIBUTES.keys.each do |attribute|
          send("#{attribute}=", attributes[attribute]) if attributes[attribute].present?
        end
      end

      def update_customer(attributes)
        set_customer_attributes(attributes)
        if valid?
          result = Braintree::Customer.update(customer_token, customer_attributes)
          handle_customer_result(result)
          result.success?
        end
      end

      def save_subscription
        if subscription
          Braintree::Subscription.update(subscription_token, :plan_id => plan_id)
        elsif plan.billed?
          valid? && create_subscription
        end
      end

      def customer_attributes
        {
          :email => billing_email,
          :credit_card => credit_card_attributes
        }
      end

      def credit_card_attributes
        if plan.billed?
          card_attributes = { :cardholder_name => cardholder_name,
                              :number => card_number,
                              :expiration_month => expiration_month,
                              :expiration_year => expiration_year,
                              :cvv => verification_code }
          if credit_card
            card_attributes.merge!(:options => credit_card_options)
          end
          card_attributes
        else 
          {}
        end
      end

      def credit_card_options
        if customer && customer.credit_cards.any?
          { :update_existing_token => credit_card.token }
        else
          {}
        end
      end

      def create_customer
        result = Braintree::Customer.create(customer_attributes)
        handle_customer_result(result)
      end

      def destroy_customer
        Braintree::Customer.delete(customer_token)
      end

      def handle_customer_result(result)
        if result.success?
          self.customer_token = result.customer.id
          flush_cache :customer
        else
          handle_errors(result.credit_card_verification, result.errors)
        end
        result.success?
      end

      def handle_errors(result, remote_errors)
        if result && result.status == "processor_declined"
          errors[:card_number] << "was denied by the payment processor with the message: #{result.processor_response_text}"
        elsif result && result.status == "gateway_rejected"
          errors[:verification_code] << "did not match"
        elsif remote_errors.any?
          remote_errors.each do |error|
            if error.attribute == "number"
              errors[:card_number] << error.message.gsub("Credit card number ", "")
            elsif error.attribute == "CVV"
              errors[:verification_code] << error.message.gsub("CVV ", "")
            elsif error.attribute == "expiration_month"
              errors[:expiration_month] << error.message.gsub("Expiration month ", "")
            elsif error.attribute == "expiration_year"
              errors[:expiration_year] << error.message.gsub("Expiration year ", "")
            end
          end
        end
      end

      def create_subscription
        result = Braintree::Subscription.create(subscription_attributes)
        if result.success?
          self.subscription_token = result.subscription.id
          self.next_billing_date = result.subscription.next_billing_date
          self.subscription_status = result.subscription.status
        else
          false
        end
      end

      def subscription_attributes
        {
          :payment_method_token => credit_card.token,
          :plan_id              => plan_id,
          :merchant_account_id  => Saucy::Configuration.merchant_account_id
        }.tap do |attributes|
          attributes.reject! { |key, value| value.nil? }
        end
      end

      def switching_to_billed?
        plan_id && plan.billed? && subscription_token.blank?
      end
    end

    module ClassMethods
      def update_subscriptions!
        recently_billed = where("next_billing_date <= ?", Time.now)
        recently_billed.each do |account|
          account.subscription_status = account.subscription.status
          account.next_billing_date = account.subscription.next_billing_date
          account.save!
          if account.past_due?
            BillingMailer.problem(account, account.subscription.transactions.last).deliver!
          else
            BillingMailer.receipt(account, account.subscription.transactions.last).deliver!
          end
        end
      end
    end
  end
end
