require 'braintree'

Braintree::Configuration.environment = :production
Braintree::Configuration.merchant_id = "xxx"
Braintree::Configuration.public_key = "xxx"
Braintree::Configuration.private_key = "xxx"

require 'digest/md5'
require 'sham_rack'

class FakeBraintree
  cattr_accessor :customers, :subscriptions, :failures, :transaction
  @@customers = {}
  @@subscriptions = {}
  @@failures = {}
  @@transaction = {}

  def self.clear!
    @@customers = {}
    @@subscriptions = {}
    @@failures = {}
    @@transaction = {}
  end

  def self.failure?(card_number)
    self.failures.include?(card_number)
  end

  def self.failure_response(card_number)
    failure = self.failures[card_number]
    failure["errors"] ||= { "errors" => [] }
    { "message" => failure["message"], "verification" => { "status" => failure["status"], "processor_response_text"  => failure["message"], "processor-response-code" => failure["code"], "gateway_rejection_reason" => "cvv", "cvv_response_code" => failure["code"] }, "errors" => failure["errors"], "params" => {}}
  end

  def self.generated_transaction
    {"status_history"=>[{"timestamp"=>Time.now, "amount"=>FakeBraintree.transaction[:amount], "transaction_source"=>"CP", "user"=>"copycopter", "status"=>"authorized"}, {"timestamp"=>Time.now, "amount"=>FakeBraintree.transaction[:amount], "transaction_source"=>"CP", "user"=>"copycopter", "status"=>FakeBraintree.transaction[:status]}], "created_at"=>(FakeBraintree.transaction[:created_at] || Time.now), "currency_iso_code"=>"USD", "settlement_batch_id"=>nil, "processor_authorization_code"=>"ZKB4VJ", "avs_postal_code_response_code"=>"I", "order_id"=>nil, "updated_at"=>Time.now, "refunded_transaction_id"=>nil, "amount"=>FakeBraintree.transaction[:amount], "credit_card"=>{"last_4"=>"1111", "card_type"=>"Visa", "token"=>"8yq7", "customer_location"=>"US", "expiration_year"=>"2013", "expiration_month"=>"02", "bin"=>"411111", "cardholder_name"=>"Chad Lee Pytel"}, "refund_id"=>nil, "add_ons"=>[], "shipping"=>{"region"=>nil, "company"=>nil, "country_name"=>nil, "extended_address"=>nil, "postal_code"=>nil, "id"=>nil, "street_address"=>nil, "country_code_numeric"=>nil, "last_name"=>nil, "locality"=>nil, "country_code_alpha2"=>nil, "country_code_alpha3"=>nil, "first_name"=>nil}, "id"=>"49sbx6", "merchant_account_id"=>"Thoughtbot", "type"=>"sale", "cvv_response_code"=>"I", "subscription_id"=>FakeBraintree.transaction[:subscription_id], "custom_fields"=>"\n    ", "discounts"=>[], "billing"=>{"region"=>nil, "company"=>nil, "country_name"=>nil, "extended_address"=>nil, "postal_code"=>nil, "id"=>nil, "street_address"=>nil, "country_code_numeric"=>nil, "last_name"=>nil, "locality"=>nil, "country_code_alpha2"=>nil, "country_code_alpha3"=>nil, "first_name"=>nil}, "processor_response_code"=>"1000", "refund_ids"=>[], "customer"=>{"company"=>nil, "id"=>"108427", "last_name"=>nil, "fax"=>nil, "phone"=>nil, "website"=>nil, "first_name"=>nil, "email"=>"cpytel@thoughtbot.com"}, "avs_error_response_code"=>nil, "processor_response_text"=>"Approved", "avs_street_address_response_code"=>"I", "status"=>FakeBraintree.transaction[:status], "gateway_rejection_reason"=>nil}
  end
end

ShamRack.at("www.braintreegateway.com", 443).sinatra do
  set :show_exceptions, false
  set :dump_errors, true
  set :raise_errors, true
  disable :logging

  post "/merchants/:merchant_id/customers" do
    customer = Hash.from_xml(request.body).delete("customer")
    if !FakeBraintree.failure?(customer["credit_card"]["number"])
      customer["id"] ||= Digest::MD5.hexdigest("#{params[:merchant_id]}#{Time.now.to_f}")
      customer["merchant-id"] = params[:merchant_id]
      if customer["credit_card"] && customer["credit_card"].is_a?(Hash)
        customer["credit_card"].delete("__content__")
        if !customer["credit_card"].empty?
          customer["credit_card"]["last_4"] = customer["credit_card"].delete("number")[-4..-1]
          customer["credit_card"]["token"] = Digest::MD5.hexdigest("#{customer['merchant_id']}#{customer['id']}#{Time.now.to_f}")
          credit_card = customer.delete("credit_card")
          customer["credit_cards"] = [credit_card]
        end
      end
      FakeBraintree.customers[customer["id"]] = customer
      [201, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(customer.to_xml(:root => 'customer'))]
    else
      [422, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(FakeBraintree.failure_response(customer["credit_card"]["number"]).to_xml(:root => 'api_error_response'))]
    end
  end

  get "/merchants/:merchant_id/customers/:id" do
    customer = FakeBraintree.customers[params[:id]]
    [200, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(customer.to_xml(:root => 'customer'))]
  end

  put "/merchants/:merchant_id/customers/:id" do
    customer = Hash.from_xml(request.body).delete("customer")
    if !FakeBraintree.failure?(customer["credit_card"]["number"])
      customer["id"] = params[:id]
      customer["merchant-id"] = params[:merchant_id]
      if customer["credit_card"] && customer["credit_card"].is_a?(Hash)
        customer["credit_card"].delete("__content__")
        if !customer["credit_card"].empty?
          customer["credit_card"]["last_4"] = customer["credit_card"].delete("number")[-4..-1]
          customer["credit_card"]["token"] = Digest::MD5.hexdigest("#{customer['merchant_id']}#{customer['id']}#{Time.now.to_f}")
          credit_card = customer.delete("credit_card")
          customer["credit_cards"] = [credit_card]
        end
      end
      FakeBraintree.customers[params["id"]] = customer
      [200, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(customer.to_xml(:root => 'customer'))]
    else
      [422, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(FakeBraintree.failure_response(customer["credit_card"]["number"]).to_xml(:root => 'api_error_response'))]
    end
  end

  delete "/merchants/:merchant_id/customers/:id" do
    FakeBraintree.customers[params["id"]] = nil
    [200, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress("")]
  end

  post "/merchants/:merchant_id/subscriptions" do
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<subscription>\n  <plan-id type=\"integer\">2</plan-id>\n  <payment-method-token>b22x</payment-method-token>\n</subscription>\n"
    subscription = Hash.from_xml(request.body).delete("subscription")
    subscription["id"] ||= Digest::MD5.hexdigest("#{subscription["payment_method_token"]}#{Time.now.to_f}")
    subscription["transactions"] = []
    subscription["add_ons"] = []
    subscription["discounts"] = []
    subscription["next_billing_date"] = 1.month.from_now
    subscription["status"] = Braintree::Subscription::Status::Active
    FakeBraintree.subscriptions[subscription["id"]] = subscription
    [201, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(subscription.to_xml(:root => 'subscription'))]
  end

  get "/merchants/:merchant_id/subscriptions/:id" do
    subscription = FakeBraintree.subscriptions[params[:id]]
    [200, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(subscription.to_xml(:root => 'subscription'))]
  end

  put "/merchants/:merchant_id/subscriptions/:id" do
    subscription = Hash.from_xml(request.body).delete("subscription")
    subscription["transactions"] = []
    subscription["add_ons"] = []
    subscription["discounts"] = []
    FakeBraintree.subscriptions[params["id"]] = subscription
    [200, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(subscription.to_xml(:root => 'subscription'))]
  end

  post "/merchants/:merchant_id/transactions/advanced_search_ids" do
    # "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<search>\n  <created-at>\n    <min type=\"datetime\">2011-01-10T14:14:26Z</min>\n  </created-at>\n</search>\n"
    [200, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress("<search-results>\n  <page-size type=\"integer\">50</page-size>\n  <ids type=\"array\">\n          <item>49sbx6</item>\n      </ids>\n</search-results>\n")]
  end

  post "/merchants/:merchant_id/transactions/advanced_search" do
    # "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<search>\n  <ids type=\"array\">\n    <item>49sbx6</item>\n  </ids>\n  <created-at>\n    <min type=\"datetime\">2011-01-10T14:14:26Z</min>\n  </created-at>\n</search>\n"
    [200, { "Content-Encoding" => "gzip" }, ActiveSupport::Gzip.compress(FakeBraintree.generated_transaction.to_xml)]
  end
end
