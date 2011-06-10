require 'saucy/fake_braintree'

RSpec.configure do |config|
  config.after(:each) { FakeBraintree.clear! }
end
