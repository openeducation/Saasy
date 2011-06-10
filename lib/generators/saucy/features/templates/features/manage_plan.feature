Feature: Manage Plan
  As a admin user
  I want to be able to upgrade and downgrade my account
  So that I can pay what I want and get the features I want

  Scenario: Change the plan to another paid plan on an account with a paid plan
    Given a paid plan exists with a name of "Basic"
    And a paid plan exists with a name of "Premium"
    And the following account exists:
      | name | keyword | plan        | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Basic | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the settings page for the "Test" account
    Then I should see "Your Plan"
    And I should not see "Billing Information"
    And I should see "Basic"
    And I follow "Upgrade"
    Then I should see "Upgrade Your Plan"
    When I choose the "Premium" plan
    And I press "Upgrade"
    Then I should see "Plan changed successfully"
    Then I should see "Premium"

  Scenario: Change the plan from free to paid
    Given a plan exists with a name of "Free"
    And a paid plan exists with a name of "Basic"
    And the following account exists:
      | name | keyword | plan       |
      | Test | test    | name: Free |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the settings page for the "Test" account
    Then I should not see "Billing" within ".subnav"
    Then I should see "Your Plan"
    And I follow "Upgrade"
    Then I should see "Upgrade Your Plan"
    When I choose the "Basic" plan
    Then I should see "Billing Information"
    And I fill in "Cardholder name" with "Ralph Robot"
    And I fill in "Billing email" with "accounting@example.com"
    And I fill in "Card number" with "4111111111111111"
    And I fill in "Verification code" with "123"
    And I select "March" from "Expiration month"
    And I select "2020" from "Expiration year"
    When I press "Upgrade"
    Then I should see "Plan changed successfully"
    And I should see "Basic"
    And I follow "Billing"
    Then I should see "card ending in 1111"

  Scenario: Change the plan from free to paid with an invalid credit card number
    Given that the credit card "4111112" is invalid
    And a plan exists with a name of "Free"
    And a paid plan exists with a name of "Basic"
    And the following account exists:
      | name | keyword | plan       |
      | Test | test    | name: Free |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the settings page for the "Test" account
    Then I should not see "Billing" within ".subnav"
    Then I should see "Your Plan"
    And I follow "Upgrade"
    When I choose the "Basic" plan
    Then I should see "Billing Information"
    And I fill in "Cardholder name" with "Ralph Robot"
    And I fill in "Billing email" with "accounting@example.com"
    And I fill in "Card number" with "4111112"
    And I fill in "Verification code" with "123"
    And I select "March" from "Expiration month"
    And I select "2020" from "Expiration year"
    When I press "Upgrade"
    Then I should not see "Plan changed successfully"
    And "Card number" should have the error "is invalid"

  Scenario: Change the plan to a free on an account with a paid plan
    Given a paid plan exists with a name of "Basic"
    And a plan exists with a name of "Free"
    And the following account exists:
      | name | keyword | plan        | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Basic | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the settings page for the "Test" account
    Then I should see "Your Plan"
    And I should not see "Billing Information"
    And I should see "Basic"
    And I follow "Upgrade"
    Then I should see "Upgrade Your Plan"
    When I choose the "Free" plan
    And I press "Upgrade"
    Then I should see "Plan changed successfully"
    Then I should see "Free"

  Scenario: Attempting to downgrade when beyond the limits
    Given a paid plan exists with a name of "Basic"
    And a plan exists with a name of "Free"
    And the following account exists:
      | name | keyword | plan        | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Basic | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And the following limits exist:
      | plan        | name     | value | value_type |
      | name: Basic | users    | 1     | number     |
      | name: Free  | users    | 0     | number     |
      | name: Basic | projects | 5     | number     |
      | name: Free  | projects | 1     | number     |
      | name: Basic | ssl      | 1     | boolean    |
      | name: Free  | ssl      | 0     | boolean    |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the settings page for the "Test" account
    Then I should see "Your Plan"
    And I should not see "Billing Information"
    And I should see "Basic"
    And I follow "Upgrade"
    Then I should see "Upgrade Your Plan"
    And the "Free" plan should be disabled
    And I should see "Too big for Free."
    And I should see "1 user" within ".basic"
    And I should see "0 users" within ".free"
    And I should see "1 project" within ".free"
    And I should see "5 projects" within ".basic"
    And I should see "ssl" within ".basic"
    And I should not see "ssl" within ".free"

  Scenario: Viewing current usage
    Given a paid plan exists with a name of "Basic"
    And the following account exists:
      | name | keyword | plan        | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Basic | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And the following limits exist:
      | plan        | name     | value | value_type |
      | name: Basic | users    | 1     | number     |
      | name: Basic | projects | 5     | number     |
      | name: Basic | ssl      | 1     | boolean    |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the settings page for the "Test" account
    Then I should see "1/1" within ".users.meter"
    And I should see "100.000%" within ".users.meter"
    And I should see "0/5" within ".projects.meter"
    And I should see "0.000%" within ".projects.meter"
