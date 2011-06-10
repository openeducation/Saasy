Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.sequence :name do |n|
  "name#{n}"
end

Factory.define :user do |user|
  user.name                  { "test user" }
  user.email                 { Factory.next :email }
  user.password              { "password" }
end

Factory.define :account do |f|
  f.name        { Factory.next(:name) }
  f.keyword     { Factory.next(:name) }
  f.association :plan
end

Factory.define :paid_account, :parent => :account do |f|
  f.cardholder_name   { "Ralph Robot"       }
  f.billing_email     { "ralph@example.com" }
  f.card_number       { "4111111111111111"  }
  f.verification_code { "123"               }
  f.expiration_month  { 5                   }
  f.expiration_year   { 2012                }
  f.association :plan, :factory => :paid_plan
end

Factory.define :membership do |f|
  f.association :user
  f.association :account
end

Factory.define :signup do |f|
  f.email                 { Factory.next :email }
  f.password              { "password" }
  f.association           :plan
end

Factory.define :project do |f|
  f.association :account
  f.name        { Factory.next(:name) }
  f.keyword     { Factory.next(:name) }
end

Factory.define :permission do |f|
  f.association :membership
  f.project     {|a| a.association(:project, :account => a.membership.account)}
end

Factory.define :invitation do |f|
  f.email { Factory.next(:email) }
  f.association :account
  f.association :sender, :factory => :user
end

Factory.define :plan do |f|
  f.name 'Free'
end

Factory.define :paid_plan, :parent => :plan do |f|
  f.name 'Paid'
  f.price 1
end

Factory.define :limit do |f|
  f.name        { Factory.next(:name) }
  f.association :plan
end
