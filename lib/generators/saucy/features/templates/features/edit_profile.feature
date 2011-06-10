Feature: edit profile

  Scenario: Normal users can edit themselves
    Given I am signed in
    When I go to the settings page
    And I fill in "Name" with "Name Change"
    And I press "Update"
    And I go to the settings page
    Then the "Name" field should contain "Name Change"
