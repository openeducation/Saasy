Feature: Sign up
  In order to get access to protected sections of the site
  A user
  Should be able to sign up

  Background:
    Given a plan exists with a name of "Free"

  Scenario: User sees signup terms
    When I go to the plans page
    Then I should see "Free"
    And I should see "Upgrade or Downgrade Anytime"
    And I there should be a link to the help site
    When I follow "Free"
    Then I should see "By clicking Sign up you agree to our Terms of Service"

  Scenario: User signs up with invalid data
    When I go to the sign up page for the "Free" plan
    Then I should see "Free"
    And I fill in "Email" with "invalidemail"
    And I fill in "Password" with "password"
    And I should not see "Billing Information"
    And I press "Sign up"
    Then the form should have inline error messages

  Scenario: User signs up with valid data
    When I go to the list of plans page
    And I follow "Free"
    And I fill in "Email" with "email@person.com"
    And I fill in "Password" with "password"
    And I press "Sign up"
    Then I should see "created"
