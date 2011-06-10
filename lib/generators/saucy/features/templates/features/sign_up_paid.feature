Feature: Sign up
  In order to get access to protected sections of the site
  A user
  Should be able to sign up

  Background:
    Given a paid plan exists with a name of "Paid"
    And a plan exists with a name of "Free"

  Scenario: User signs up for a paid plan with invalid data
    When I go to the sign up page for the "Paid" plan
    Then I should see "Paid"
    And I should see "$1/month"
    And the "Card number" field should have autocomplete off
    And the "Verification code" field should have autocomplete off
    And I fill in "Email" with "invalidemail"
    And I fill in "Password" with "password"
    And I should see "Billing Information"
    And I press "Sign up"
    Then the form should have inline error messages

  Scenario: User signs up for a paid plan with valid data
    When I go to the list of plans page
    Then I should see the "Paid" plan before the "Free" plan
    When I follow "Paid"
    And I fill in "Email" with "email@person.com"
    And I fill in "Password" with "password"
    And I fill in "Cardholder name" with "Ralph Robot"
    And I fill in "Billing email" with "accounting@example.com"
    And I fill in "Card number" with "4111111111111111"
    And I fill in "Verification code" with "123"
    And I select "March" from "Expiration month"
    And I select "2020" from "Expiration year"
    And I press "Sign up"
    Then I should see "created"

  Scenario: User signs up for a paid plan with an invalid credit card number
    Given that the credit card "4111112" is invalid
    When I go to the list of plans page
    And I follow "Paid"
    And I fill in "Email" with "email@person.com"
    And I fill in "Password" with "password"
    And I fill in "Cardholder name" with "Ralph Robot"
    And I fill in "Billing email" with "accounting@example.com"
    And I fill in "Card number" with "4111112"
    And I fill in "Verification code" with "123"
    And I select "March" from "Expiration month"
    And I select "2020" from "Expiration year"
    And I press "Sign up"
    Then "Card number" should have the error "is invalid"

  Scenario: User signs up for a paid plan with a credit card that cannot be processed
    Given that the credit card "4111111111111111" should not be honored
    When I go to the list of plans page
    And I follow "Paid"
    And I fill in "Email" with "email@person.com"
    And I fill in "Password" with "password"
    And I fill in "Cardholder name" with "Ralph Robot"
    And I fill in "Billing email" with "accounting@example.com"
    And I fill in "Card number" with "4111111111111111"
    And I fill in "Verification code" with "123"
    And I select "March" from "Expiration month"
    And I select "2020" from "Expiration year"
    And I press "Sign up"
    Then "Card number" should have the error "Do Not Honor"
