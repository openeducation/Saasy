class Invitation < ActiveRecord::Base
  belongs_to :account
  belongs_to :sender, :class_name => 'User'
  validates_presence_of :account_id
  validates_presence_of :email
  has_and_belongs_to_many :projects

  before_create :generate_code
  after_create :deliver_invitation

  attr_accessor :new_user_name, :new_user_password, :authenticating_user_password, :existing_user
  attr_writer :new_user_email, :authenticating_user_email
  attr_protected :account_id, :used
  attr_reader :user

  validate :validate_accepting_user, :on => :update

  def account_name
    account.name
  end

  def accept(attributes)
    self.attributes = attributes
    self.used = true
    @user = existing_user || authenticating_user || new_user
    if valid?
      transaction do
        save!
        @user.save!
        @user.memberships.create!(:account  => account,
                                  :admin    => admin,
                                  :projects => projects)
      end
    end
  end

  def new_user_email
    @new_user_email ||= email
  end

  def authenticating_user_email
    @authenticating_user_email ||= email
  end

  def to_param
    code
  end

  def sender_name
    sender.name
  end

  def sender_email
    sender.email
  end

  private

  def deliver_invitation
    InvitationMailer.invitation(self).deliver
  end

  def existing_user?
    existing_user.present?
  end

  def authenticating_user
    if authenticating_user?
      User.find_by_email(authenticating_user_email)
    end
  end

  def authenticating_user?
    authenticating_user_password.present?
  end

  def new_user
    User.new(
      :email                 => new_user_email,
      :password              => new_user_password,
      :name                  => new_user_name
    )
  end

  def validate_accepting_user
    if authenticating_user?
      validate_authenticating_user
    elsif existing_user?
      true
    else
      validate_new_user
    end
  end

  def validate_new_user
    user.valid?
    user.errors.each do |field, message|
      errors.add("new_user_#{field}", message)
    end
  end

  def validate_authenticating_user
    if authenticating_user.nil?
      errors.add(:authenticating_user_email, "isn't signed up")
    elsif !authenticating_user.authenticated?(authenticating_user_password)
      errors.add(:authenticating_user_password, "is incorrect")
    end
  end

  def generate_code
    self.code = SecureRandom.hex(8)
  end
end
