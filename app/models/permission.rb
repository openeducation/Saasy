class Permission < ActiveRecord::Base
  belongs_to :membership
  belongs_to :project
  belongs_to :user

  before_validation :assign_user_id_from_membership

  validates_uniqueness_of :membership_id, :scope => :project_id

  def user=(ignored)
    raise NotImplementedError, "Use Permission#membership= instead"
  end

  private

  def assign_user_id_from_membership
    self.user_id = membership.user_id
  end
end
