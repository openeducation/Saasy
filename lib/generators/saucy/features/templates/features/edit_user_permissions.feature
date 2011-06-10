Feature: edit permissions for a user

  As an admin,
  I can edit permissions for which users are on which projects and vice versa.

  Scenario: edit permissions for a user
    Given the following projects exists:
      | name  | account          |
      | Alpha | name: thoughtbot |
      | Beta  | name: thoughtbot |
      | Delta | name: other      |
    Given the following user exists:
      | name | email           |
      | Sam  | sam@example.com |
    And I am signed in as an admin of the "thoughtbot" account
    And "sam@example.com" is a member of the "Alpha" project
    When I go to the settings page for the "thoughtbot" account
    And I follow "Users"
    And I follow "Sam"
    Then the "Alpha" checkbox should be checked
    And the "Beta" checkbox should not be checked
    And I should not see "Delta"
    When I check "Beta"
    And I uncheck "Alpha"
    And I press "Update"
    Then I should see "Permissions updated"
    When I follow "Sam"
    Then the "Alpha" checkbox should not be checked
    And the "Beta" checkbox should be checked
    And I should not see "Delta"

  Scenario: promote a user to an admin
    Given an account exists with a name of "Test"
    And I am signed in as an admin of the "Test" account
    And an user exists with a name of "Frank"
    And the following memberships exist:
      | account    | user        | admin |
      | name: Test | name: Frank | false |
    When I go to the memberships page for the "Test" account
    And I follow "Frank"
    And I check "Admin"
    And I press "Update"
    Then I should see "Permissions updated"
    When I go to the memberships page for the "Test" account
    And I follow "Frank"
    Then the "Admin" checkbox should be checked

