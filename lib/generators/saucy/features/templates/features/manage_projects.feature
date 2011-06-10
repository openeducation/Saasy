Feature: Manage Projects
  As a admin user
  I want to be able to manage projects
  In order to have a project for each of my software applications

  Background:
    Given the following accounts exist:
      | name    | keyword    |
      | Test    | test       |
      | Another | another    |
    And the following user exists:
      | name     | email           |
      | Joe User | joe@example.com |
    And "joe@example.com" is an admin of the "Test" account
    And I sign in as "joe@example.com"

  Scenario: Create new project with one account
    When I go to the projects page for the "Test" account
    And I follow "New Project"
    Then the page should not include "select#project_account_id"
    And the "Joe User" checkbox should be checked
    When I fill in "Name" with "Project 1"
    And I fill in "Keyword" with "project1"
    And I should see "http://www.example.com/accounts/test/projects/keyword"
    And I press "Create"
    And I go to the projects page for the "Test" account
    Then I should see "Project 1" within "ul.projects"

  Scenario: Creating new project with two accounts shows the account selection
    Given "joe@example.com" is an admin of the "Another" account
    When I go to the projects page for the "Test" account
    And I follow "New Project"
    Then the page should include "select#project_account_id"

  Scenario: Edit a project
    Given the following project exists:
      | account    | name      |
      | name: Test | Project 1 |
    When I go to the projects page for the "Test" account
    And I follow "Project 1" within "ul.projects"
    And I fill in "Name" with "Name Change"
    And I press "Update"
    Then I should see "Name Change"

  @javascript
  Scenario: Move a project
    Given "joe@example.com" is an admin of the "Another" account
    And the following projects exist:
      | account    | name      |
      | name: Test | Project 1 |
    When I go to the projects page for the "Test" account
    And I follow "Project 1" within "ul.projects"
    And I select "Another" from "Account"
    And I press "Update"
    And I should see "Project 1" within "ul.projects"
    Then I should be on the projects page for the "Another" account

  @javascript
  Scenario: Move a project when account being moved to is at the account limit
    Given "joe@example.com" is an admin of the "Another" account
    And the following limit exists for the "Another" account:
      | name     | value |
      | projects | 1     |
    And the following projects exist:
      | account       | name      |
      | name: Test    | Project 1 |
      | name: Another | Project 2 |
    When I go to the projects page for the "Test" account
    And I follow "Project 1" within "ul.projects"
    And I select "Another" from "Account"
    And I press "Update"
    Then I should see "at your limit"
    When I go to the projects page for the "Test" account
    Then I should see "Project 1"

  Scenario: Archive a project
    Given the following project exists:
      | account    | name      |
      | name: Test | Project 1 |
    When I go to the projects page for the "Test" account
    And I follow "Project 1" within "ul.projects"
    And I check "Archived"
    And I press "Update"
    And I should see "Project 1" within "ul.projects.archived"

  Scenario: Unarchive a project
    Given the following project exists:
      | account    | name      | archived |
      | name: Test | Project 1 | true     |
    When I go to the projects page for the "Test" account
    And I follow "Project 1" within "ul.projects.archived"
    And I uncheck "Archived"
    And I press "Update"
    And I should see "Project 1" within "ul.projects.active"

  Scenario: Unarchive a project when at the account limit
    Given the following limit exists for the "Test" account:
      | name     | value |
      | projects | 1     |
    And the following projects exist:
      | account       | name      | archived |
      | name: Test    | Project 1 | false    |
      | name: Test    | Project 2 | true     |
    When I go to the projects page for the "Test" account
    And I follow "Project 2"
    And I uncheck "Archived"
    And I press "Update"
    Then I should see "at your limit"
    When I go to the projects page for the "Test" account
    And I should see "Project 1" within "ul.projects.active" 
    And I should see "Project 2" within "ul.projects.archived"

  Scenario: View all projects
    Given the following projects exist:
      | account       | name      | archived |
      | name: Test    | Project 1 | false    |
      | name: Test    | Project 2 | false    |
      | name: Test    | Project 3 | true     |
      | name: Other   | Project 3 | false    |
      | name: Another | Project 4 | false    |
    And "joe@example.com" is a member of the "Other" account
    When I go to the projects page for the "Test" account
    Then I should see "Project 1" within "ul.projects.active"
    And I should see "Project 2" within "ul.projects.active"
    And I should see "Project 3" within "ul.projects.archived"
    But I should not see "Project 3" within "ul.projects"
    And I should not see "Project 4" within "ul.projects"

  Scenario: Create new project when at the account limit
    Given the following limit exists for the "Test" account:
      | name     | value |
      | projects | 1     |
    And the following project exists:
      | account       | name      |
      | name: Test    | Project 1 |
    When I go to the projects page for the "Test" account
    And I follow "New Project"
    Then I should be on the projects page for the "Test" account
    And I should see "at your limit"
