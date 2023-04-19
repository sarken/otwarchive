@works @tags
Feature: Edit Works
  In order to have an archive full of works
  As an author
  I want to edit existing works

  Scenario: You can't edit a work unless you're logged in and it's your work
    Given I have loaded the fixtures
    # I'm not logged in
    When I view the work "First work"
    Then I should not see "Edit"
    Given I am logged in as "testuser" with password "testuser"
      And all indexing jobs have been run
    # This isn't my work
    When I view the work "fourth"
    Then I should not see "Edit"
    When I am on testuser's works page
    # These are my works and should all have edit links on the blurbs
    Then I should see "Edit"
    When I follow "First work"
    # This is my individual work and should have an edit link on the show page
    Then I should see "first fandom"
      And I should see "Edit"
      # make sure this tag isn't on before we add it
      And I should not see "new tag"
    When I follow "Edit"
    Then I should see "Edit Work"
    When I fill in "work_freeform" with "new tag"
      And I fill in "content" with "first chapter content"
      And I press "Preview"
    Then I should see "Preview"
      And I should see "Fandom: first fandom"
      # line below fails with perform_caching: true because of issue 3461
      # And I should see "Additional Tags: new tag"
      And I should see "first chapter content"
      And I should see "Words:3"
    When I press "Update"
    Then I should see "Work was successfully updated."
      And I should see "Additional Tags: new tag"
      And I should see "Words:3"
    When all indexing jobs have been run
      And I go to testuser's works page
    Then I should see "First work"
      And I should see "first fandom"
      And I should see "new tag"
    When I edit the work "First work"
      And I follow "Add Chapter"
      And I fill in "content" with "second chapter content"
      And I press "Preview"
    Then I should see "This is a draft chapter in a posted work. It will be kept unless the work is deleted."
      And I should see "second chapter content"
    When I press "Post"
    Then I should see "Chapter was successfully posted."
      And I should not see "first chapter content"
      And I should see "second chapter content"
      And I should see "Words:6"
    When I edit the work "First work"
    Then I should not see "chapter content"
    When I follow "1"
      And I fill in "content" with "first chapter new content"
      And I press "Preview"
    Then I should see "first chapter new content"
    When I press "Update"
    Then I should see "Chapter was successfully updated."
      And I should see "first chapter new content"
      And I should not see "second chapter content"
      And I should see "Words:7"
    When I edit the work "First Work"
      And I follow "2"
      And I fill in "content" with "second chapter new content"
      And I press "Preview"
      And I press "Cancel"
    Then I should see "second chapter content"
      And I should see "Words:7"
    # Test changing pseuds on a work
    When I go to testuser's works page
      And I follow "Edit"
      And I select "testy" from "work_author_attributes_ids"
      And I unselect "testuser" from "work_author_attributes_ids"
      And I press "Post"
    Then I should see "testy"
      And I should not see "testuser,"

  Scenario: Editing a work in a moderated collection
    # TODO: Find a way to appove works without using this hack method I have here
    Given the following activated users exist
      | login          | password   |
      | Scott          | password   |
      And I have a moderated collection "Digital Hoarders 2013" with name "digital_hoarders_2013"
    When I am logged in as "Scott" with password "password"
      And I post the work "Murder in Milan" in the collection "Digital Hoarders 2013"
    Then I should see "You have submitted your work to the moderated collection 'Digital Hoarders 2013'. It will not become a part of the collection until it has been approved by a moderator."
    When I am logged in as "moderator"
      And I go to "Digital Hoarders 2013" collection's page
      And I follow "Collection Settings"
      And I uncheck "This collection is moderated"
      And I press "Update"
    Then I should see "Collection was successfully updated"
    When I am logged in as "Scott"
      And I post the work "Murder by Numbers" in the collection "Digital Hoarders 2013"
    Then I should see "Work was successfully posted"
    When I am logged in as "moderator"
      And I go to "Digital Hoarders 2013" collection's page
      And I follow "Collection Settings"
      And I check "This collection is moderated"
      And I press "Update"
    Then I should see "Collection was successfully updated"
    When I am logged in as "Scott"
      And I edit the work "Murder by Numbers"
      And I press "Post"
      And I should see "Work was successfully updated"
    Then I should not see "You have submitted your work to the moderated collection 'Digital Hoarders 2013'. It will not become a part of the collection until it has been approved by a moderator."

  Scenario: Previewing edits to a posted work should not refer to the work as a draft
    Given I am logged in as "editor"
      And I post the work "Load of Typos"
    When I edit the work "Load of Typos"
      And I press "Preview"
    Then I should not see "draft"

  Scenario: Previewing shows changes to tags, but cancelling afterwards doesn't save those changes
    Given I am logged in as a random user
      And I post the work "Work 1" with fandom "testing"
    When I edit the work "Work 1"
      And I fill in "Fandoms" with "foobar"
      And I press "Preview"
    Then I should see "Fandom: foobar"
    When I press "Cancel"
      And I view the work "Work 1"
    Then I should see "Fandom: testing"
      And I should not see "Fandom: foobar"

  Scenario: A work cannot be edited to remove its fandom
    Given basic tags
      And I am logged in as a random user
      And I post the work "Work 1" with fandom "testing"
    When I edit the work "Work 1"
      And I fill in "Fandoms" with ""
      And I press "Post"
    Then I should see "Sorry! We couldn't save this work because: Please fill in at least one fandom."
    When I view the work "Work 1"
    Then I should see "Fandom: testing"

  Scenario: User can cancel editing a work
    Given I am logged in as a random user
      And I post the work "Work 1" with fandom "testing"
      And I edit the work "Work 1"
      And I fill in "Fandoms" with ""
      And I press "Cancel"
    When I view the work "Work 1"
    Then I should see "Fandom: testing"

  Scenario: A work cannot be edited to remove its only warning
    Given I am logged in as a random user
      And I post the work "Work 1"
    When I edit the work "Work 1"
      And I uncheck "No Archive Warnings Apply"
      And I press "Post"
    Then I should see "Sorry! We couldn't save this work because: Please select at least one warning."
    When I view the work "Work 1"
    Then I should see "Archive Warning: No Archive Warnings Apply"

  Scenario: A work can be edited to remove all categories
    Given I am logged in as a random user
      And I post the work "Work 1" with category "F/F"
    When I edit the work "Work 1"
      And I uncheck "F/F"
      And I press "Post"
    Then I should not see "F/F"

  Scenario: When editing a work, the title field should not escape HTML
    Given I have a work "What a title! :< :& :>"
      And I go to the works page
      And I follow "What a title! :< :& :>"
      And I follow "Edit"
    Then I should see "What a title! :< :& :>" in the "Work Title" input

  Scenario: You cannot edit a work to add too many tags
    Given the user-defined tag limit is 7
      And the work "Over the Limit"
      And I am logged in as the author of "Over the Limit"
    When I edit the work "Over the Limit"
      And I fill in "Fandoms" with "Fandom 1, Fandom 2"
      And I fill in "Characters" with "Character 1, Character 2"
      And I fill in "Relationships" with "Relationship 1, Relationship 2"
      And I fill in "Additional Tags" with "Additional Tag 1, Additional Tag 2"
      And I press "Post"
    Then I should see "Fandom, relationship, character, and additional tags must not add up to more than 7. Your work has 8 of these tags, so you must remove 1 of them."

  Scenario: If a work has too many tags, you cannot update it without removing tags
    Given the user-defined tag limit is 7
      And the work "Over the Limit"
      And the work "Over the Limit" has 2 fandom tags
      And the work "Over the Limit" has 2 character tags
      And the work "Over the Limit" has 2 relationship tags
      And the work "Over the Limit" has 2 freeform tags
      And I am logged in as the author of "Over the Limit"
    When I edit the work "Over the Limit"
      And I fill in "Title" with "Over the Limit Redux"
      And I press "Post"
    Then I should see "Fandom, relationship, character, and additional tags must not add up to more than 7. Your work has 8 of these tags, so you must remove 1 of them."
