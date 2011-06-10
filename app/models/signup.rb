# Responsible for handling the combo User/Account creation. Also deals with
# Account creation when signing in as an existing User.
class Signup
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  FIELDS = {
    :account => {
      :cardholder_name => :cardholder_name, 
      :billing_email => :billing_email, 
      :card_number => :card_number, 
      :expiration_month => :expiration_month, 
      :expiration_year => :expiration_year,
      :verification_code => :verification_code,
      :plan => :plan
    },
    :user => {
      :email    => :email,
      :password => :password,
    }
  }.freeze

  attr_accessor :billing_email, :password, :cardholder_name, :email, 
    :card_number, :expiration_month, :expiration_year, :plan, :verification_code

  def initialize(attributes = {})
    if attributes
      attributes.each do |attribute, value|
        send(:"#{attribute}=", value)
      end
    end
    @check_password = true
  end

  # used by ActiveModel
  def persisted?
    false
  end

  def save
    delegate_attributes_for(:account)
    populate_additional_account_fields

    if !existing_user
      delegate_attributes_for(:user) 
      populate_additional_user_fields
    end

    if valid?
      begin
        save!
        true
      rescue ActiveRecord::RecordNotSaved
        delegate_errors_for(:account)
        delegate_errors_for(:user)
        false
      end
    else
      false
    end
  end

  def account
    @account ||= Account.new
  end

  def user
    existing_user || new_user
  end

  def user=(signed_in_user)
    @check_password = false
    @existing_user  = signed_in_user
  end

  def new_user
    @new_user ||= User.new
  end

  def existing_user
    @existing_user ||= User.find_by_email(email)
  end

  def membership
    @membership ||= Membership.new(:user    => user,
                                   :account => account,
                                   :admin   => true)
  end

  def valid?
    errors.clear
    validate
    errors.empty?
  end

  private

  def short_name
    if email.present?
      email.split(/@/).first.parameterize
    elsif user && user.email.present?
      existing_user.email.split(/@/).first.parameterize
    end
  end

  def populate_additional_account_fields
    account.name = "#{short_name}"
    account.keyword = "#{short_name}#{SecureRandom.hex(3)}"
  end

  def populate_additional_user_fields
    user.name = short_name
  end

  def delegate_attributes_for(model_name)
    FIELDS[model_name].each do |target, source|
      send(model_name).send(:"#{target}=", send(source))
    end
  end

  def delegate_errors
    FIELDS.each do |model_name, fields|
      delegate_errors_for(model_name, fields)
    end
  end

  def delegate_errors_for(model_name)
    fields = FIELDS[model_name]
    send(model_name).errors.each do |field, message|
      errors.add(fields[field], message) if fields[field]
    end
  end

  def validate
    account.valid?
    delegate_errors_for(:account)
    if existing_user
      validate_existing_user
    else
      validate_new_user
    end
  end

  def validate_new_user
    new_user.valid?
    delegate_errors_for(:user)
  end

  def validate_existing_user
    if @check_password && !existing_user.authenticated?(password)
      errors.add(:password, "is incorrect")
    end
  end

  def save!
    Account.transaction do
      account.save!
      user.save!
      membership.save!
    end
  end
end
