Feature: Manage Billing
  As a admin user
  I want to be able to manage my billing information
  So that my account can stay up to date and in good standing

  Scenario: Update the billing information on an account with a paid plan
    Given a paid plan exists with a name of "Paid"
    And the following account exists:
      | name | keyword | plan       | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Paid | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the billing page for the "Test" account
    Then I should see "card ending in 5555"
    And I should see "There have been no invoices yet."
    And I follow "Change" within ".current_credit_card"

    Then the "Cardholder name" field should contain "Joe Smith"
    And the "Billing email" field should contain "jsmith@example.com"
    And the "Card number" field should have nothing in it
    And the "Verification code" field should have nothing in it
    And the "Expiration month" field should contain "01"
    And the "Expiration year" field should contain "2015"

    And I fill in "Cardholder name" with "Ralph Robot"
    And I fill in "Billing email" with "accounting@example.com"
    And I fill in "Card number" with "4111111111111111"
    And I fill in "Verification code" with "123"
    And I select "March" from "Expiration month"
    And I select "2020" from "Expiration year"
    And I press "Update"
    Then I should see "updated successfully"
    Then I should see "card ending in 1111"

  Scenario: Be forced to update the billing information on an account with a paid plan that is past due
    Given a paid plan exists with a name of "Paid"
    And the following account exists:
      | name | keyword | plan       | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Paid | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And the "Test" account is past due
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the settings page for the "Test" account
    Then I should be on the billing page for the "Test" account
    And I should see "There was an issue processing the credit card you have on file. Please update your credit card information."

  Scenario: Be told to have an admin update the billing information on an account with a paid plan that is past due
    Given a paid plan exists with a name of "Paid"
    And the following account exists:
      | name | keyword | plan       | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Paid | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And the "Test" account is past due
    And the following projects exist:
      | name     | account    |
      | Project  | name: Test |
      | Project2 | name: Test |
    And the following user exists:
      | email              |
      | jsmith@example.com |
    And "jsmith@example.com" is a member of the "Project" project
    And I sign in as "jsmith@example.com"
    When I go to the accounts page
    Then I should see "There was an issue processing the credit card on file for this account. Please have an administrator on the account update the credit card information."
    Then I should be on the billing page for the "Test" account

  Scenario: View past credit card charges
    Given a paid plan exists with a name of "Paid"
    And the following account exists:
      | name | keyword | plan       | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Paid | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And the following transaction exist for the "Test" account:
      | status  | amount | created_at        |
      | Settled | 20.00  | July 1, 2010      |
      | Settled | 5.00   | August 1, 2010    |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the billing page for the "Test" account
    Then I should see "Your Invoices"
    And I should see "07/01/10 $20"
    And I should see "08/01/10 $5"

  Scenario: Navigate back to the main settings page
    Given a paid plan exists with a name of "Paid"
    And the following account exists:
      | name | keyword | plan       | cardholder_name | billing_email      | card_number      | verification_code | expiration_month | expiration_year |
      | Test | test    | name: Paid | Joe Smith       | jsmith@example.com | 4111111111115555 | 122               | 01               | 2015            |
    And I have signed in with "joe@example.com/test"
    And "joe@example.com" is an admin of the "Test" account
    When I go to the billing page for the "Test" account
    And I follow "Change"
    And I follow "Billing"
    And I follow "Account Info"
    Then I should be on the settings page for the "Test" account
