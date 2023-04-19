@works @tags
Feature: Co-create works
  In order to properly credit people I make works with
  As a creator
  I want to have co-creators on works

  Scenario: Users can co-create a work with a co-creator who has multiple pseuds
    Given basic tags
      And "myself" has the pseud "Me"
      And "herself" has the pseud "Me"
      And the user "myself" allows co-creators
      And the user "herself" allows co-creators
    When I am logged in as "testuser" with password "testuser"
      And I go to the new work page
      And I fill in the basic work information for "All Hell Breaks Loose"
      And I check "Add co-creators?"
      And I fill in "pseud_byline" with "Me"
      And I check "This work is part of a series"
      And I fill in "Or create and use a new one:" with "My new series"
      And I press "Post"
    Then I should see "There's more than one user with the pseud Me."
      And I select "myself" from "Please choose the one you want:"
      And I press "Preview"
    Then I should see "Draft was successfully created."
      And I press "Post"
    Then I should see "Work was successfully posted. It should appear in work listings within the next few minutes."
      And I should not see "Me (myself)"
      And I should see "My new series"
    When the user "myself" accepts all co-creator requests
      And I view the work "All Hell Breaks Loose"
    Then I should see "Me (myself), testuser"

  Scenario: Users can only create a work with a co-creator who allows it.
    Given basic tags
      And "Burnham" has the pseud "Michael"
      And "Pike" has the pseud "Christopher"
      And the user "Burnham" allows co-creators
    When I am logged in as "testuser" with password "testuser"
      And I go to the new work page
      And I fill in the basic work information for "Thats not my Spock"
      And I check "Add co-creators?"
      And I fill in "pseud_byline" with "Michael,Christopher"
      And I press "Post"
    Then I should see "Christopher (Pike) does not allow others to invite them to be a co-creator."
    When I fill in "pseud_byline" with "Michael"
      And I press "Preview"
    Then I should see "Draft was successfully created."
    When I press "Post"
    Then I should see "Work was successfully posted. It should appear in work listings within the next few minutes."
      But I should not see "Michael (Burnham)"
    When the user "Burnham" accepts all co-creator requests
      And I view the work "Thats not my Spock"
    Then I should see "Michael (Burnham), testuser"

  Scenario: Inviting a co-author adds the co-author to all existing chapters when they accept the invite
    Given the user "foobar" exists and is activated
      And the user "barbaz" exists and is activated

    When I am logged in as "foobar"
      And I post the chaptered work "Chaptered Work"
      And I edit the work "Chaptered Work"
      And I invite the co-author "barbaz"
      And I press "Post"
    Then I should not see "barbaz"
      But 1 email should be delivered to "barbaz"
    When I am logged in as "barbaz"
      And I view the work "Chaptered Work"
    Then I should not see "Edit"
    # Delay to make sure that the cache expires when we accept the request:
    When it is currently 1 second from now
      And I follow "Co-Creator Requests page"
      And I check "selected[]"
      And I press "Accept"
    Then I should see "You are now listed as a co-creator on Chaptered Work."
    When I follow "Chaptered Work"
    Then I should see "Edit"
      And I should see "barbaz, foobar"
      And I should not see "Chapter by"
    When I follow "Next Chapter"
    Then I should see "barbaz, foobar"
      And I should not see "Chapter by"

  Scenario: You can invite a co-author to an already-posted work
    Given I am logged in as "leadauthor"
      And the user "coauthor" exists and is activated
      And the user "coauthor" allows co-creators
      And I post the work "Dialogue"
    When I follow "Edit"
      And I invite the co-author "coauthor"
      And I press "Post"
    Then I should see "Work was successfully updated"
      And I should not see "coauthor" within ".byline"
      But 1 email should be delivered to "coauthor"
      And the email should contain "The user leadauthor has invited your pseud coauthor to be listed as a co-creator on the following work"
    When I am logged in as "coauthor"
      And I follow "Dialogue" in the email
    Then I should not see "Edit"
    When I follow "Co-Creator Requests page"
      And I check "selected[]"
      # Expire cached byline
      And it is currently 1 second from now
      And I press "Accept"
    Then I should see "You are now listed as a co-creator on Dialogue."
    When I follow "Dialogue"
    Then I should see "coauthor, leadauthor" within ".byline"
      And I should see "Edit"

  Scenario: You can remove yourself as coauthor from a work
    Given the following activated users exist
        | login          |
        | coolperson     |
        | ex_friend      |
      And the user "ex_friend" allows co-creators
      And I coauthored the work "Shared" as "coolperson" with "ex_friend"
      And I am logged in as "coolperson"
    When I view the work "Shared"
    Then I should see "coolperson, ex_friend" within ".byline"
    When I edit the work "Shared"
      And I wait 1 second
      And I follow "Remove Me As Co-Creator"
    Then I should see "You have been removed as a creator from the work."
      And "ex_friend" should be the creator on the work "Shared"
      And "coolperson" should not be a creator on the work "Shared"

  Scenario: User applies a coauthor's work skin to their work
    Given the following activated users with private work skins
        | login       |
        | lead_author |
        | coauthor    |
        | random_user |
      And the user "coauthor" allows co-creators
      And I coauthored the work "Shared" as "lead_author" with "coauthor"
      And I am logged in as "lead_author"
    When I edit the work "Shared"
    Then I should see "Lead Author's Work Skin" within "#work_work_skin_id"
      And I should see "Coauthor's Work Skin" within "#work_work_skin_id"
      And I should not see "Random User's Work Skin" within "#work_work_skin_id"
    When I select "Coauthor's Work Skin" from "Select Work Skin"
      And I press "Post"
    Then I should see "Work was successfully updated"

  Scenario: When a user changes their co-creator preference, it does not remove them from works they have already co-created.
    Given basic tags
      And "Burnham" has the pseud "Michael"
      And "Pike" has the pseud "Christopher"
      And the user "Burnham" allows co-creators
    When I am logged in as "testuser" with password "testuser"
      And I go to the new work page
      And I fill in the basic work information for "Thats not my Spock"
      And I try to invite the co-authors "Michael,Christopher"
      And I press "Post"
    Then I should see "Christopher (Pike) does not allow others to invite them to be a co-creator."
    When I press "Post"
    Then I should see "Work was successfully posted. It should appear in work listings within the next few minutes."
      But I should not see "Michael"
    When the user "Burnham" accepts all co-creator requests
      And I view the work "Thats not my Spock"
    Then I should see "Michael (Burnham), testuser"
    When the user "Burnham" disallows co-creators
      And I edit the work "Thats not my Spock"
      And I fill in "Work Title" with "Thats not my Spock, it has too much beard"
      And I press "Post"
    Then I should see "Thats not my Spock, it has too much beard"
      And I should see "Michael (Burnham), testuser"

  Scenario: When you have a work with two co-creators, and one of them changes their preference to disallow co-creation, the other should still be able to edit the work and add a third co-creator.
    Given basic tags
      And "Burnham" has the pseud "Michael"
      And "Georgiou" has the pseud "Philippa"
      And the user "Burnham" allows co-creators
      And the user "Georgiou" allows co-creators
    When I am logged in as "testuser" with password "testuser"
      And I go to the new work page
      And I fill in the basic work information for "Thats not my Spock"
      And I try to invite the co-author "Michael"
      And I press "Post"
    Then I should see "Work was successfully posted. It should appear in work listings within the next few minutes."
      But I should not see "Michael"
    When the user "Burnham" accepts all co-creator requests
      And I view the work "Thats not my Spock"
    Then I should see "Michael (Burnham), testuser"
    When the user "Burnham" disallows co-creators
      And I edit the work "Thats not my Spock"
      And I fill in "Work Title" with "Thats not my Spock, it has too much beard"
      And I press "Post"
    Then I should see "Thats not my Spock, it has too much beard"
      And I should see "Michael (Burnham), testuser"
    When I edit the work "Thats not my Spock, it has too much beard"
      And I invite the co-author "Georgiou"
      And I press "Post"
    Then I should see "Work was successfully updated"
      And I should see "Michael (Burnham), testuser"
      But I should not see "Georgiou"
    When the user "Georgiou" accepts all co-creator requests
      And I view the work "Thats not my Spock, it has too much beard"
    Then I should see "Georgiou, Michael (Burnham), testuser"
