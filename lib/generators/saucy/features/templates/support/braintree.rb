require 'saucy/fake_braintree'

After do |s| 
  FakeBraintree.clear!
end
