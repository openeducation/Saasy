Feature: user adds a new account

  Background:
    Given a plan exists with a name of "Free"

  Scenario: existing user adds an account
    Given I am signed up as "user@example.com/test"
    When I go to the sign up page for the "Free" plan
    And I fill in "Email" with "user@example.com"
    And I fill in "Password" with "test"
    And I press "Sign up"
    Then I should see "created"
    But I should not see "Instructions for confirming"
    And I should be on the new project page for the newest account by "user@example.com"

  Scenario: sign up for two accounts
    When I go to the sign up page for the "Free" plan
    And I fill in "Email" with "email@person.com"
    And I fill in "Password" with "password"
    And I press "Sign up"
    Then I should see "created"
    And I should be on the new project page for the newest account by "email@person.com"
    When I go to the settings page
    Then I should see 1 account
    And I follow "Add new account"
    And I follow "Free"
    Then I should see "Your existing user, email, will be added as the first administrator on this new account."
    And I press "Sign up"
    Then I should see "created"
    But I should not see "Instructions for confirming"
    And I should be on the new project page for the newest account by "email@person.com"
    When I go to the settings page
    Then I should see 2 accounts
