Feature: Trial plans

  Background:
    Given the following plan exists:
      | name    | price | trial |
      | Temp    | 0     | true  |
      | Eternal | 0     | false |
    And the following limits exist:
      | plan          | name  | value | value_type |
      | name: Temp    | users | 2     | number     |
      | name: Eternal | users | 2     | number     |

  Scenario: Sign up for a trial plan
    When I go to the list of plans page
    And I follow "Temp"
    Then I should see "Free"
    And I should see "Trial"
    And I should see "Your trial will expire after 30 days"
    But I should not see "users"
    When I fill in "Email" with "email@person.com"
    And I fill in "Password" with "password"
    And I press "Sign up"
    Then I should see "created"

  Scenario: use an account during the trial
    Given a "Temp" account exists with a name of "Test" created 29 days ago
    And I am signed in as an admin of the "Test" account
    When I go to the projects page for the "Test" account
    Then I should see "Test"
    And I should not see "expired"

  Scenario: Try to use an expired trial plan
    Given a "Temp" account exists with a name of "Test" created 30 days ago
    And I am signed in as an admin of the "Test" account
    When I go to the projects page for the "Test" account
    Then I should be on the upgrade plan page for the "Test" account
    And I should see "expired"
    And the "Temp" plan should be disabled

  Scenario: Sign up for a non-trial plan
    When I go to the list of plans page
    And I follow "Eternal"
    Then I should see "users"
    But I should not see "Trial"
    And I should not see "expire"

  Scenario: Use a non-trial plan forever
    Given an "Eternal" account exists with a name of "Test" created 30 days ago
    And I am signed in as an admin of the "Test" account
    When I go to the projects page for the "Test" account
    Then I should see "Test"
    And I should not see "expired"

  Scenario: Receive a reminder about an expiring trial plan
    Given a "Temp" account exists with a name of "Test" created 23 days ago
    And a user exists with an email of "admin@example.com"
    And "admin@example.com" is an admin of the "Test" account
    When the daily Saucy jobs are processed
    And I sign in as "admin@example.com"
    And I follow the link sent to "admin@example.com" with subject "Your trial is expiring soon"
    Then I should be on the upgrade plan page for the "Test" account

  Scenario: Receive a reminder about activating an account
    Given an account exists with a name of "Test"
    And a user exists with an email of "admin@example.com"
    And "admin@example.com" is an admin of the "Test" account
    And the "Test" account was created 7 days ago
    When the daily Saucy jobs are processed
    Then an email with subject "A check in" should be sent to "admin@example.com"
    When I sign in as "admin@example.com/password"
    And I follow the link sent to "admin@example.com" with subject "A check in"
    Then I should be on the new project page for the newest account by "admin@example.com"

  Scenario: Receive a reminder about an expired trial plan
    Given a "Temp" account exists with a name of "Test" created 30 days ago
    And a user exists with an email of "admin@example.com"
    And "admin@example.com" is an admin of the "Test" account
    When the daily Saucy jobs are processed
    And I sign in as "admin@example.com"
    And I follow the link sent to "admin@example.com" with subject "Your trial has ended"
    Then I should be on the upgrade plan page for the "Test" account

