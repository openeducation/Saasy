module AuthorizationHelpers
  module AccountAdminExampleGroup
    extend ActiveSupport::Concern
    included do
      let(:account) { Factory(:account) }
      before { sign_in_as_admin_of_account(account) }
    end
  end

  module AccountMemberExampleGroup
    extend ActiveSupport::Concern
    included do
      let(:account) { Factory(:account) }
      before { sign_in_as_non_admin_of_account(account) }
    end
  end

  module ProjectAdminExampleGroup
    extend ActiveSupport::Concern
    included do
      let(:account) { Factory(:account) }
      let(:project) { Factory(:project, :account => account) }
      before { sign_in_as_admin_of_project(project) }
    end
  end

  module ProjectMemberExampleGroup
    extend ActiveSupport::Concern
    included do
      let(:account) { Factory(:account) }
      let(:project) { Factory(:project, :account => account) }
      before { sign_in_as_non_admin_of_project(project) }
    end
  end

  module UserExampleGroup
    extend ActiveSupport::Concern
    included do
      let(:user) { Factory(:user) }
      before { sign_in_as(user) }
    end
  end
end

RSpec.configure do |config|
  config.include AuthorizationHelpers::AccountAdminExampleGroup,
    :as => :account_admin
  config.include AuthorizationHelpers::AccountMemberExampleGroup,
    :as => :account_member
  config.include AuthorizationHelpers::ProjectAdminExampleGroup,
    :as => :project_admin
  config.include AuthorizationHelpers::ProjectMemberExampleGroup,
    :as => :project_member
  config.include AuthorizationHelpers::UserExampleGroup,
    :as => :user
end
