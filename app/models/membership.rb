class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  has_many :permissions, :dependent => :destroy
  has_many :projects, :through => :permissions

  validates_presence_of :user_id
  validates_presence_of :account_id
  validates_uniqueness_of :user_id, :scope => :account_id

  def self.admin
    where(:admin => true)
  end

  def name
    user.name
  end

  def email
    user.email
  end

  def self.by_name
    joins(:user).order('users.name')
  end
end
