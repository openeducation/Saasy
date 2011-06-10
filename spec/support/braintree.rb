require 'saucy/fake_braintree'

Braintree::Configuration.logger = Logger.new("tmp/log")

RSpec.configure do |config|
  config.after(:each) { FakeBraintree.clear! }
end
