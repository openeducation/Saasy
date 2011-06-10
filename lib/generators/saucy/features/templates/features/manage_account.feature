Feature: Manage account
  As a user
  In order to properly represent my organization
  I want to be able to edit account details

  Scenario: Edit account details
    Given an account exists with a name of "Test"
    And I am signed in as an admin of the "Test" account
    When I go to the settings page
    And I follow "Test"
    When I fill in "Account name" with "Name Change"
    And I press "Update"
    When I follow "Name Change"
    Then the "Account name" field should contain "Name Change"

  Scenario: Account Settings Tab Bar
    Given an account exists with a name of "Test"
    And I am signed in as an admin of the "Test" account
    And a project named "Projection" exists under the "Test" account
    And the user "captain@awesome.com" exists under the "Test" account
    When I go to the settings page for the "Test" account
    And I follow "Projects" within ".subnav"
    Then I should see "Projection"
    When I follow "Users"
    Then I should see "captain@awesome.com"

  Scenario: Delete account
    Given an account exists with a name of "Chocolate"
    And I am signed in as an admin of the "Chocolate" account
    When I go to the settings page for the "Chocolate" account
    And I follow "Delete"
    Then I should see "Your account has been deleted"
    When I go to the dashboard page
    Then I should not see "Chocolate"

