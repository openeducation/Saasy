module AuthenticationHelpers
  def sign_in_as(user)
    controller.current_user = user
  end

  def sign_in
    sign_in_as(Factory(:user))
  end

  def sign_out
    controller.current_user = nil
  end

  def current_user
    controller.current_user
  end

  def signed_in?
    controller.signed_in?
  end

  def sign_in_as_admin_of_account(account)
    user = Factory(:user)
    Factory(:membership, :user => user, :account => account, :admin => true)
    sign_in_as user
  end

  def sign_in_as_non_admin_of_account(account)
    user = Factory(:user)
    Factory(:membership, :user => user, :account => account, :admin => false)
    sign_in_as user
  end

  def sign_in_as_non_admin_of_project(project)
    user = Factory(:user)
    membership = Factory(:membership, :user    => user,
                                                      :account => account,
                                                      :admin   => false)
    Factory(:permission, :membership => membership,
                                 :project            => project)
    sign_in_as user
  end

  def sign_in_as_admin_of_project(project)
    user = Factory(:user)
    membership = Factory(:membership, :user    => user,
                                                      :account => account,
                                                      :admin   => true)
    Factory(:permission, :membership => membership,
                                 :project            => project)
    sign_in_as user
  end
end

RSpec::Matchers.define :be_signed_in do
  match do |controller|
    @controller = controller
    @controller.signed_in? &&
      (@expected_user.nil? || @expected_user == @controller.current_user)
  end

  chain :as do |user|
    @expected_user = user
  end

  failure_message_for_should do
    message = "expected to be signed in"
    message << " as #{@expected_user.inspect}" if @expected_user
    message << " but was "
    if @controller.signed_in?
      message << "signed in as #{@controller.current_user.inspect}"
    else
      message << "not signed in"
    end
    message
  end

  failure_message_for_should_not do
    "didn't expect to be signed in"
  end
end
