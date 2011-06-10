require 'saucy/layouts'

module Saucy
  class Configuration
    cattr_reader   :layouts
    cattr_accessor :manager_email_address
    cattr_accessor :support_email_address
    cattr_accessor :merchant_account_id
    cattr_accessor :observers

    def initialize
      @@manager_email_address = 'manager@example.com'
      @@support_email_address = 'support@example.com'
      @@layouts       = Layouts.new
      @@observers     = []
    end

    def self.observe(observer)
      @@observers << observer
    end

    def self.notify(event, data)
      @@observers.each do |observer|
        observer.send(event, data)
      end
    end
  end
end

