Feature: edit permissions for a project

  As an admin,
  I can manage permissions for each project in my account, so only project
  members can edit blurbs.

  Scenario: edit permissions for a project
    Given the following project exists:
      | name       | account          |
      | Stocknames | name: thoughtbot |
    And the following users exist:
      | name | email            |
      | Bill | bill@example.com |
      | Jane | jane@example.com |
      | Jeff | jeff@example.com |
      | Hank | hank@example.com |
    And I am signed in as an admin of the "Stocknames" project
    And "bill@example.com" is a member of the "Stocknames" project
    And "jane@example.com" is a member of the "thoughtbot" account
    And "hank@example.com" is an admin of the "Stocknames" project
    When I go to the settings page for the "thoughtbot" account
    And I follow "Projects" within ".subnav"
    And I follow "Stocknames" within "ul.projects"
    Then "Bill" should be listed as a member
    And "Hank" should be listed as an admin
    And "Jane" should be listed as a non-member
    And I should not see "Jeff"
    When I check "Jane"
    And I uncheck "Bill"
    And I press "Update"
    Then I should see "Project was updated"
    When I follow "Stocknames" within "ul.projects"
    Then the "Bill" checkbox should not be checked
    And the "Jane" checkbox should be checked
    And the "Hank" checkbox should be checked
    And I should not see "Jeff"

