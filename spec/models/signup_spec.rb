require 'spec_helper'

describe Signup do
  it "complies with the activemodel api" do
    subject.class.should be_kind_of(ActiveModel::Naming)
    should_not be_persisted
    should be_kind_of(ActiveModel::Conversion)
    should be_kind_of(ActiveModel::Validations)
  end
end

describe Signup, "with attributes in the constructor" do
  subject { Signup.new(:email => 'person@example.com', :password => 'password') }
  it "assigns attributes" do
    subject.email.should == 'person@example.com'
    subject.password.should == 'password'
  end
end

describe Signup, "with nil to the constructor" do
  subject { Signup.new(nil) }

  it "assigns no attributes" do
    subject.email.should be_blank
    subject.password.should be_blank
  end
end

share_examples_for "invalid signup" do
  before { @previous_user_count = User.count }

  it "returns false" do
    @result.should be_false
  end

  it "doesn't create a user" do
    User.count.should == @previous_user_count
  end

  it "doesn't create an account" do
    subject.account.should be_new_record
  end
end

share_examples_for "valid signup" do
  it "returns true" do
    @result.should be_true
  end

  it "saves the account" do
    subject.account.should be_persisted
  end
end

describe Signup, "with a valid user and account" do
  it_should_behave_like "valid signup"
  let(:email) { "user@example.com" }
  subject { Factory.build(:signup, :email => email) }

  before do
    @result = subject.save
  end

  it "saves the user" do
    subject.user.should be_persisted
  end

  it "assigns the user to the account" do
    subject.user.reload.accounts.should include(subject.account)
  end

  it "creates an admin user" do
    subject.user.should be_admin_of(subject.account)
  end

  it "gives a friendly account name" do
    subject.account.name.should == "user"
  end

  it "gives a friendly account keyword" do
    subject.account.keyword.should =~ /^user.+/
  end

  it "gives it's account a name and keyword" do
    subject.account.name.should_not be_blank
    subject.account.keyword.should_not be_blank
  end

  it "gives it's user a name that is the first part of it's email" do
    subject.user.name.should == "user"
  end
end

describe Signup, "with an email with symbols in it" do
  subject { Factory.build(:signup, :email => "user+extra@example.com") }

  before do
    subject.save
  end
  
  it "gives a friendly account name" do
    subject.account.name.should == "user-extra"
  end

  it "gives a friendly account keyword" do
    subject.account.keyword.should =~ /^user-extra+/
  end
end

describe Signup, "with an invalid user" do
  subject { Factory.build(:signup, :email => nil) }
  it_should_behave_like "invalid signup"

  before do
    @result = subject.save
  end

  it "adds error messages" do
    subject.errors[:email].should_not be_empty
  end
end

describe Signup, "valid with an existing user and correct password" do
  it_should_behave_like "valid signup"
  let(:email) { "user@example.com" }
  let(:password) { "test" }
  let!(:user) { Factory(:user, :email => email, :password => password) }
  subject { Factory.build(:signup, :email => email, :password => password) }
  before { @result = subject.save }

  it "doesn't create a user" do
    User.count.should == 1
  end

  it "assigns the user to the account as an admin" do
    user.reload.accounts.should include(subject.account)
    user.should be_admin_of(subject.account)
  end
end

describe Signup, "valid with a signed in user" do
  it_should_behave_like "valid signup"
  let!(:user) { Factory(:user) }
  subject { Factory.build(:signup, :user => user, :password => '') }
  before { @result = subject.save }

  it "doesn't create a user" do
    User.count.should == 1
  end

  it "assigns the user to the account as an admin" do
    user.reload.accounts.should include(subject.account)
    user.should be_admin_of(subject.account)
  end
end

describe Signup, "valid with an existing user and incorrect password" do
  it_should_behave_like "invalid signup"
  let(:email) { "user@example.com" }
  let(:password) { "test" }
  let!(:user) { Factory(:user, :email => email, :password => password) }
  subject { Factory.build(:signup, :email => email, :password => 'wrong') }
  before { @result = subject.save }

  it "adds error messages" do
    subject.errors.full_messages.should include("Password is incorrect")
  end
end

describe Signup, "with an account that doesn't save" do
  subject { Factory.build(:signup) }

  it "doesn't raise the transaction and returns false" do
    Account.any_instance.stubs(:save!).raises(ActiveRecord::RecordNotSaved)
    subject.save.should_not be
  end
end
