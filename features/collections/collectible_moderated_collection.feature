@bookmarks @collections @works
Feature: Collectible items in moderated collections
  As a user
  I want to add my items to moderated collections

  Background:
    Given I have a moderated collection "Various Penguins"
      And I am logged in as a random user

  Scenario: Add my work to a moderated collection with the Add to Collections 
  button
    Given I post the work "Blabla"
    When I add my work to the collection
    Then I should see "until it has been approved by a moderator."
    When I go to "Various Penguins" collection's page
    Then I should see "Works (0)"
      And I should not see "Blabla"

  Scenario: Add my work to a moderated collection by editing the work
    Given I post the work "Blabla"
    When I edit the work "Blabla"
      And I fill in "Post to Collections / Challenges" with "various_penguins"
      And I press "Preview"
    Then I should see "the moderated collection 'Various Penguins'"
    When I press "Update"
    Then I should see "the moderated collection 'Various Penguins'"

  Scenario: Add my bookmark to a moderated collection
    Given I have a bookmark for "Tundra penguins"
    When I add my bookmark to the collection "Various_Penguins"
    Then I should see "until it has been approved by a moderator."
    When I go to "Various Penguins" collection's page
    Then I should see "Bookmarked Items (0)"
      And I should not see "Tundra penguins"

  Scenario: Bookmarks of deleted items are included on a moderated collection's
  Awaiting Approval Manage Items page
    Given I have a bookmark of a deleted work
      And I add my bookmark to the collection "Various_Penguins"
    When I am logged in as the owner of "Various Penguins"
      And I view the awaiting approval collection items page for "Various Penguins"
    Then I should see "Bookmark of deleted item"
      And I should see "This has been deleted, sorry!"

  Scenario: Revealing a moderated collection reveal all of its items
    Given I am logged in as the owner of "Various Penguins"
      And I set the collection "Various Penguins" to unrevealed
      And I am logged in as a random user
      And I post the work "Approved Work" to the collection "Various Penguins"
      And I post the work "Unapproved Work" to the collection "Various Penguins"
      And I post the work "Rejected Work" to the collection "Various Penguins"
    When I am logged in as the owner of "Various Penguins"
      And I view the awaiting approval collection items page for "Various Penguins"
      And I approve the collection item for the work "Approved Work"
    Then I should see "Collection status updated!"
    When I view the awaiting approval collection items page for "Various Penguins"
      And I reject the collection item for the work "Rejected Work"
    When I reveal works for "Various Penguins"
      And I view the work "Approved Work"
    Then I should not see "This work is part of an ongoing challenge and will be revealed soon!"
    When I view the work "Unapproved Work"
    Then I should not see "This work is part of an ongoing challenge and will be revealed soon!"
    When I view the work "Rejected Work"
    Then I should not see "This work is part of an ongoing challenge and will be revealed soon!"
