@tags @tag_wrangling
Feature: Media tags

  Scenario: Wranglers do not have the option to create media tags
    Given I am logged in as a tag wrangler
    When I go to the new tag page
    Then I should not see "Media" within "#new_tag"

  Scenario: Admins can create media tags and then make them canonical
    Given I am logged in as an admin
    When I go to the new tag page
      And I fill in "Name" with "New Media 1"
      And I choose "Media"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      # Fails because "Media" is not an option -- "Fandom" is selected
      # and the tag gets converted to a fandom when saving
      And "Media" should be selected within "Category"
    When I check "Canonical"
    And I press "Save changes"
    Then I should see "Tag was updated."

  Scenario: Admins can create canonical media tags
    Given I am logged in as an admin
    When I go to the new tag page
      And I fill in "Name" with "New Media 2"
      And I check "Canonical"
      And I choose "Media"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."

  Scenario: New media tags are added to the Fandoms menu
    Given I have just created the canonical media tag "New Media 3"
      And I am logged out
    When I go to the homepage
    Then I should see "New Media 3" within "#header .primary .dropdown .menu"
    When I follow "New Media 3" within "#header .primary .dropdown .menu"
    Then I should see "Fandoms > New Media 3"
      And I should see "No fandoms found" 

  Scenario: New media tags are added to the Fandoms menu
    Given I have just created the canonical media tag "New Media 4"
    When I go to the fandoms page
    Then I should see "New Media 4" within "#main .media"
    When I follow "New Media 4" within "#main .media"
    Then I should see "Fandoms > New Media 4"
      And I should see "No fandoms found"

  @javascript
  Scenario: Wranglers can add fandoms to new media tags
    Given I have just created the canonical media tag "New Media 5"
      And a canonical fandom "Canonical Fandom"
      And I am logged in as a tag wrangler
    When I edit the tag "Canonical Fandom"
      And I choose "New Media 5" from the "tag_media_string_autocomplete" autocomplete
      And I press "Save changes"
    Then I should see "Tag was updated."
    When I go to the "New Media 5" fandoms page
    Then I should see "Canonical Fandom"

      