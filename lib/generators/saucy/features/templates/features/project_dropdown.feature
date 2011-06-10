Feature: Project Dropdown
  As a user
  So that I can work on several projects
  I can easily switch between projects

  Background:
    Given I am signed in as "user@example.com" under the "Werther's" account
    And the following projects exist:
      | name     | account         |
      | Pacelog  | name: Werther's |
      | Narrator | name: Werther's |
      | Flapper  | name: Werther's |
    And "user@example.com" is a member of the "Pacelog" project

  @javascript
  Scenario: Navigate from one project to another
    Given "user@example.com" is a member of the "Narrator" project
    When I go to the "Pacelog" project page
    Then the page should not include "#project-selection ul.expanded"
    When I click "#project-selection h1 a img"
    Then the page should include "#project-selection ul.expanded"
    And I should not see "Flapper"
    When I follow "Narrator" within "#project-selection ul"
    Then I should be on the "Narrator" project page

  @javascript
  Scenario: Click outside the projects dropdown to hide it
    Given "user@example.com" is a member of the "Narrator" project
    When I go to the "Narrator" project page
    Then the page should not include "#project-selection ul.expanded"
    When I click "#project-selection h1 a img"
    Then the page should include "#project-selection ul.expanded"
    When I click "body"
    Then the page should not include "#project-selection ul.expanded"

  Scenario: On project pages, the project name is rendered in the header
    When I go to the "Pacelog" project page
    Then I should see "Pacelog" within "#project-selection h1 a"

  Scenario: On project pages with multiple projects, the project name and chooser are rendered in the header
    Given "user@example.com" is a member of the "Narrator" project
    When I go to the "Pacelog" project page
    Then I should see "Pacelog" within "#project-selection h1 a"
    And the page should include "#project-selection h1 a img"

  Scenario: On non-project pages, the account name is rendered in the header with the project chooser
    Given "user@example.com" is an admin of the "Narrator" project
    When I am on the memberships page for the "Werther's" account
    Then I should see "Projects" within "#project-selection h1 a"
    And the page should include "#project-selection h1 a img"

    When I am on the edit profile page
    Then I should see "Projects" within "#project-selection h1 a"
    And the page should include "#project-selection h1 a img"

  Scenario: An admin on non-project pages, the new project link goes to the new project page for the right account
    Given "user@example.com" is an admin of the "Narrator" project
    When I am on the edit profile page
    Then I should see "Create a new project" within "#project-selection"
    When I follow "Create a new project"
    Then I should be on the new project page for the "Werther's" account

  Scenario: An admin on project pages, the new project link goes to the new project page for the right account
    Given "user@example.com" is an admin of the "Narrator" project
    When I go to the "Pacelog" project page
    Then I should see "Create a new project" within "#project-selection"
    When I follow "Create a new project"
    Then I should be on the new project page for the "Werther's" account

  Scenario: A non-admin on non-project pages, should not see the new project link
    Given "user@example.com" is a member of the "Narrator" project
    When I am on the edit profile page
    Then I should not see "Create a new project" within "#project-selection"

  Scenario: A non-admin on project pages, should not see the new project link
    When I go to the "Pacelog" project page
    Then I should not see "Create a new project" within "#project-selection"
