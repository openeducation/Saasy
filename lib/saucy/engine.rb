require "saucy"
require "rails"
require "braintree"

module Saucy
  class Engine < Rails::Engine
    config.saucy = Configuration.new

    initializer :braintree_logger, :after => :initialize_logger do
      Braintree::Configuration.logger = Rails.logger
    end

    initializer :filter_credit_card_info do
      Rails.configuration.filter_parameters += [:password,
                                                :card_number,
                                                :cardholder_name,
                                                :verification_code,
                                                :expiration_month,
                                                :expiration_year]
    end

    initializer 'limits.helper' do |app|
      ActionView::Base.send :include, LimitsHelper
    end

    {:short_date => "%x"}.each do |k, v|
      Time::DATE_FORMATS[k] = v
    end

    rake_tasks do
      load "saucy/railties/tasks.rake"
    end 
  end
end

