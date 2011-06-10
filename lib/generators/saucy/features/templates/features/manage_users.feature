Feature: Managing users
  As a admin user
  In order to use the site with others
  I want to be able to invite users, edit them and their permissions

  Background:
    Given an account exists with a name of "Test"
    And I am signed in as an admin of the "Test" account
    And I am on the memberships page for the "Test" account
    And the following projects exist:
      | account    | name          |
      | name: Test | See me        |
      | name: Test | Can't find me |

  Scenario: Invite new users
    When I follow "Invite user"
    And I fill in "Email" with "invitee@example.com"
    And I check "See me"
    And I press "Invite User"
    Then I should see "invited"
    When I sign out
    And I follow the link sent to "invitee@example.com"
    And I fill in the following new user:
      | Name             | Billy  |
      | Password         | secret |
    And I press "Accept Invitation"
    Then I should be signed in
    And "invitee@example.com" should be a member of the "See me" project
    And "invitee@example.com" should be a member of the "Test" account
    But "invitee@example.com" should not be a member of the "Can't find me" project
    When I go to the settings page
    Then the "Name" field should contain "Billy"

  Scenario: Invite existing user who is not signed in
    Given the following user exists:
      | email               | password |
      | invitee@example.com | secret   |
    When I follow "Invite user"
    And I fill in "Email" with "invitee@example.com"
    And I press "Invite User"
    Then I should see "invited"
    When I sign out
    And I follow the link sent to "invitee@example.com"
    And I fill in the following existing user:
      | Password | secret |
    And I press "Accept Invitation"
    Then I should be signed in
    And "invitee@example.com" should be a member of the "Test" account

  Scenario: Invite existing user who is signed in
    Given the following user exists:
      | email               | password |
      | invitee@example.com | secret   |
    When I follow "Invite user"
    And I fill in "Email" with "invitee@example.com"
    And I press "Invite User"
    Then I should see "invited"
    When I sign out
    When I sign in as "invitee@example.com/secret"
    And I follow the link sent to "invitee@example.com"
    Then I should be signed in
    And "invitee@example.com" should be a member of the "Test" account

  Scenario: Fail to accept an invitation
    Given the following invitation exists:
      | email               |
      | invitee@example.com |
    When I follow the link sent to "invitee@example.com"
    And I press "Accept Invitation"
    Then the form should have inline error messages

  Scenario: Invite admin users
    Given the following user exists:
      | email               | password |
      | invitee@example.com | secret   |
    When I follow "Invite user"
    And I fill in "Email" with "invitee@example.com"
    And I check "Grant administrator privileges"
    And I press "Invite User"
    And I sign out
    And I follow the link sent to "invitee@example.com"
    And I fill in the following existing user:
      | Password | secret |
    And I press "Accept Invitation"
    Then I should be signed in
    And "invitee@example.com" should be an admin member of the "Test" account

  Scenario: invalid invitation
    When I follow "Invite user"
    And I press "Invite User"
    Then the form should have inline error messages

  Scenario: view account members
    Given the following users exist:
      | name  |
      | Bill  |
      | John  |
      | Frank |
    And the following memberships exist:
      | account    | user        |
      | name: Test | name: Bill  |
      | name: Test | name: Frank |
    When I go to the memberships page for the "Test" account
    Then I should see "Bill"
    And I should see "Frank"
    And I should not see "John"

  Scenario: remove a user from an account
    Given an user exists with a name of "Frank"
    And the following memberships exist:
      | account    | user        |
      | name: Test | name: Frank |
    When I go to the memberships page for the "Test" account
    And I follow "Frank"
    Then I should see "Frank belongs to these projects:"
    And I should see "Frank is an Admin on Test"
    When I follow "Remove Frank from Test"
    Then I should see "User removed"
    And I should be on the memberships page for the "Test" account
    And I should not see "Frank"

  Scenario: remove yourself from an account
    Given an user exists with a name of "Frank"
    And the following memberships exist:
      | account    | user        |
      | name: Test | name: Frank |
    When I go to the settings page
    And I fill in "Name" with "My Name"
    And I press "Update"
    When I go to the memberships page for the "Test" account
    And I follow "My Name"
    When I follow "Remove My Name from Test"
    Then I should see "User removed"
    Then I should be on the settings page

  Scenario: Invite new user when at the account limit
    Given the following limit exists for the "Test" account:
      | name  | value |
      | users | 1     |
    When I follow "Invite user"
    Then I should be on the memberships page for the "Test" account
    And I should see "at your limit"
