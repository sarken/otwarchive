@users
Feature: Edit preferences
  In order to customize my archive experience
  As a humble user
  I want to set my preferences

  # Note: See preferences.feature for list of where preferences are tested.

  Scenario: View and edit preferences - show/hide mature content warning

  Given an adult canonical rating exists with name: "Mature"
  When I am logged in as "mywarning1"
  And I post the work "Adult Work by mywarning1"
  When I edit the work "Adult Work by mywarning1"
    And I select "Mature" from "Rating"
    And I press "Preview"
    And I press "Update"
  When I am logged in as "mywarning2"
    And I go to my preferences page
    And I check "Show me adult content without checking."
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "Adult Work by mywarning1"
  Then I should not see "adult content"
    And I should see "Rating: Mature"
  When I go to my preferences page
    And I uncheck "Show me adult content without checking."
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "Adult Work by mywarning1"
  Then I should see "adult content"
    And I should not see "Rating: Mature"

  Scenario: User sets preference to hide work skins by default, but can still
  display them on individual works.

  Given basic skins
    And I am logged in
    And I set up the draft "Big and Loud"
    And I select "Basic Formatting" from "Select Work Skin"
    And I press "Post Without Preview"
  When I view the work "Big and Loud"
  Then I should see "#workskin .font-murkyyellow" within "style"
    And I should see "Hide Creator's Style"
  When I go to my preferences page
  Then the "Hide work skins (you can still choose to show them)." checkbox should not be checked
  When I check "Hide work skins (you can still choose to show them)."
    And I press "Update"
    And I view the work "Big and Loud"
  Then I should not see "#workskin .font-murkyyellow"
    And I should not see "Hide Creator's Style"
    And I should see "Show Creator's Style"
  When I follow "Show Creator's Style"
  Then I should see "#workskin .font-murkyyellow" within "style"
    And I should see "Hide Creator's Style"
