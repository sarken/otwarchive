@works @tags
Feature: Co-create chaptered works
  In order to properly credit people I make works with
  As a creator
  I want to have co-creators on chaptered works

  Scenario: Posting a new chapter with a co-creator does not add them to previous or subsequent chapters

    Given I am logged in as "karma" with password "the1nonly"
      And the user "sabrina" allows co-creators
      And I post the work "Summer Friends"
    When a chapter is set up for "Summer Friends"
      And I invite the co-author "sabrina"
      And I post the chapter
    Then I should not see "sabrina"
    When the user "sabrina" accepts all co-creator requests
      And I view the work "Summer Friends"
    Then I should see "karma, sabrina"
      And I should see "Chapter by karma"
    When I follow "Next Chapter"
    Then I should not see "Chapter by"
    When a chapter is set up for "Summer Friends"
    Then I should see "Current co-creators"
      And the "sabrina" checkbox should not be checked
    When I post the chapter
    Then I should see "Chapter by karma"

  Scenario: You can edit a pre-existing chapter to invite a new co-creator

    Given I am logged in as "karma" with password "the1nonly"
      And the user "amy" allows co-creators
      And I post the work "Forever Friends"
      And a chapter is added to "Forever Friends"
    When I view the work "Forever Friends"
      And I view the 2nd chapter
      And I follow "Edit Chapter"
      And I invite the co-author "amy"
      And I post the chapter
    Then I should not see "amy, karma"
      And 1 email should be delivered to "amy"
      And the email should contain "The user karma has invited your pseud amy to be listed as a co-creator on the following chapter"
      And the email should not contain "translation missing"
    When the user "amy" accepts all co-creator requests
      And I view the work "Forever Friends"
    Then I should see "amy, karma"
      And I should see "Chapter by karma"
    When I follow "Next Chapter"
    Then I should not see "Chapter by"

  Scenario: You can edit a chapter to add (not invite) a co-creator who is
  already on the work

    Given I am logged in as "karma" with password "the1noly"
      And I post the work "Past Friends"
      And a chapter with the co-author "sabrina" is added to "Past Friends"
      And all emails have been delivered
      And a chapter is added to "Past Friends"
    When I view the work "Past Friends"
      And I view the 3rd chapter
    Then I should see "Chapter by karma"
    When I follow "Edit Chapter"
    Then the "sabrina" checkbox should not be checked
    When I check "sabrina"
      # Expire cached byline
      And it is currently 1 second from now
      And I post the chapter
    Then I should not see "Chapter by karma"
      And 1 email should be delivered to "sabrina"
      And the email should contain "The user karma has listed your pseud sabrina as a co-creator on the following chapter"
      And the email should contain "a co-creator on a work, you can be added to new chapters regardless of your co-creation settings. You will also be added to any series the work is added to."
      And the email should not contain "translation missing"

  Scenario: Editing a chapter with a co-creator does not allow you to remove the co-creator

    Given I am logged in as "karma" with password "the1noly"
      And I post the work "Camp Friends"
      And a chapter with the co-author "sabrina" is added to "Camp Friends"
    When I follow "Edit Chapter"
    Then the "sabrina" checkbox should be checked and disabled

  Scenario: Removing yourself as a co-creator from the chapter edit page when
  you've co-created multiple chapters on the work removes you only from that 
  specific chapter. Removing yourself as a co-creator from the chapter edit page
  of the last chapter you've co-created also removes you from the work.

    Given the work "OP's Work" by "originalposter" with chapter two co-authored with "opsfriend"
      And a chapter with the co-author "opsfriend" is added to "OP's Work"
      And I am logged in as "opsfriend"
    When I view the work "OP's Work"
      And I view the 3rd chapter
      And I follow "Edit Chapter"
    When I follow "Remove Me As Chapter Co-Creator"
    Then I should see "You have been removed as a creator from the chapter."
      And I should see "Chapter 1"
    When I view the 3rd chapter
    Then I should see "Chapter 3"
      And I should see "Chapter by originalposter"
    When I follow "Previous Chapter"
      And I follow "Edit Chapter"
      And I follow "Remove Me As Chapter Co-Creator"
    Then I should see "You have been removed as a creator from the work."
    When I view the work "OP's Work"
    Then I should not see "Edit Chapter"

  Scenario: Removing yourself as a co-creator from the chapter manage page

    Given the work "OP's Work" by "originalposter" with chapter two co-authored with "opsfriend"
      And a chapter with the co-author "opsfriend" is added to "OP's Work"
      And I am logged in as "opsfriend"
    When I view the work "OP's Work"
      And I follow "Edit"
      And I follow "Manage Chapters"
    When I follow "Remove Me As Chapter Co-Creator"
    Then I should see "You have been removed as a creator from the chapter."
      And I should see "Chapter 1"
    When I view the 2nd chapter
    Then I should see "Chapter by originalposter"

  Scenario: The option to remove yourself as a co-creator should only be
  included for chapters you are a co-creator of

    Given the work "OP's Work" by "originalposter" with chapter two co-authored with "opsfriend"
      And I am logged in as "opsfriend"
    When I view the work "OP's Work"
      And I follow "Edit"
      And I follow "Manage Chapters"
    Then the Remove Me As Chapter Co-Creator option should not be on the 1st chapter
      And the Remove Me As Chapter Co-Creator option should be on the 2nd chapter
    When I view the work "OP's Work"
      And I follow "Edit Chapter"
    Then I should not see "Remove Me As Chapter Co-Creator"
    When I view the work "OP's Work"
      And I view the 2nd chapter
      And I follow "Edit Chapter"
    Then I should see "Remove Me As Chapter Co-Creator"

  Scenario: You should be able to edit a chapter you are not already co-creator
  of, and you will be added to the chapter as a co-creator and your changes will
  be saved

    Given I am logged in as "originalposter"
      And the user "opsfriend" allows co-creators
      And I post the work "OP's Work"
      And a chapter with the co-author "opsfriend" is added to "OP's Work"
    When I am logged in as "opsfriend"
      And I view the work "OP's Work"
    Then I should see "Chapter 1"
      And I should see "Chapter by originalposter"
    When I follow "Edit Chapter"
    Then I should not see "You're not allowed to use that pseud."
    When I fill in "content" with "opsfriend was here"
      And I post the chapter
    Then I should see "opsfriend was here"
      And I should not see "Chapter by originalposter"

  Scenario: You should be able to add a chapter with two co-creators, one of
  whom is already on the work and the other of whom is not

    Given I am logged in as "rusty"
      And the user "sharon" allows co-creators
      And the user "brenda" allows co-creators
      And I set up the draft "Rusty Has Two Moms"
      And I invite the co-author "brenda"
      And I post the work without preview
      And the user "brenda" accepts all co-creator requests
    When a chapter is set up for "Rusty Has Two Moms"
      And I invite the co-author "sharon"
      And I check "brenda"
      And I post the chapter
    Then I should see "brenda, rusty"
      And I should not see "Chapter by"
    When the user "sharon" accepts all co-creator requests
      And I view the work "Rusty Has Two Moms"
    Then I should see "brenda, rusty, sharon"
      And I should see "Chapter by brenda, rusty"
    When I follow "Next Chapter"
    Then I should not see "Chapter by"

  Scenario: You should be able to add a chapter with two co-creators who are not
  on the work, one of whom has an ambiguous pseud

    Given "thebadmom" has the pseud "sharon"
      And "thegoodmom" has the pseud "sharon"
      And the user "brenda" allows co-creators
      And the user "thebadmom" allows co-creators
      And the user "thegoodmom" allows co-creators
      And I am logged in as "rusty"
      And I post the work "Rusty Has Two Moms"
    When a chapter is set up for "Rusty Has Two Moms"
      And I try to invite the co-authors "sharon, brenda"
      And I post the chapter
    Then I should see "The pseud sharon is ambiguous."
    When I select "thegoodmom" from "There's more than one user with the pseud sharon."
      And I press "Post"
    Then I should not see "brenda"
      And I should not see "sharon"
      But 1 email should be delivered to "brenda"
      And 1 email should be delivered to "thegoodmom"
    When the user "brenda" accepts all co-creator requests
      And the user "thegoodmom" accepts all co-creator requests
      And I view the work "Rusty Has Two Moms"
    Then I should see "brenda, rusty, sharon (thegoodmom)"

  Scenario: You should be able to add a chapter with two co-creators, one of
  whom is already on the work and the other of whom has an ambiguous pseud

    Given "thebadmom" has the pseud "sharon"
      And the user "thegoodmom" allows co-creators
      And the user "thebadmom" allows co-creators
      And "thegoodmom" has the pseud "sharon"
      And I am logged in as "rusty"
      And I set up the draft "Rusty Has Two Moms"
      And I invite the co-author "brenda"
      And I post the work without preview
      And the user "brenda" accepts all co-creator requests
    When a chapter is set up for "Rusty Has Two Moms"
      And I invite the co-author "sharon"
      And I check "brenda"
      And I post the chapter
    Then I should see "The pseud sharon is ambiguous."
    When I select "thegoodmom" from "There's more than one user with the pseud sharon."
      And I press "Post"
    Then I should see "brenda, rusty"
    When the user "thegoodmom" accepts all co-creator requests
      And I view the work "Rusty Has Two Moms"
    Then I should see "brenda, rusty, sharon (thegoodmom)"

  Scenario: You should be able to invite a co-creator to a chapter if they allow it.

    Given the user "brenda" allows co-creators
      And I am logged in as "rusty"
      And I post the work "Rusty Has Two Moms"
    When a chapter is set up for "Rusty Has Two Moms"
      And I invite the co-author "brenda"
      And I press "Post"
    Then I should see "Chapter has been posted!"
      And I should not see "brenda"
      But 1 email should be delivered to "brenda"
      And the email should contain "The user rusty has invited your pseud brenda to be listed as a co-creator on the following chapter"
      And the email should not contain "translation missing"
    When I am logged in as "brenda"
      And I follow "Rusty Has Two Moms" in the email
    Then I should not see "Edit"
    When I follow "Co-Creator Requests page"
      And I check "selected[]"
      # Delay before accepting the request to make sure the cache is expired:
      And it is currently 1 second from now
      And I press "Accept"
    Then I should see "You are now listed as a co-creator on Chapter 2 of Rusty Has Two Moms."
    When I follow "Rusty Has Two Moms"
    Then I should see "brenda, rusty"
      And I should see "Edit"

  Scenario: You should not be able to invite a co-creator to a chapter if they do not allow it.

    Given the user "brenda" disallows co-creators
      And I am logged in as "rusty"
      And I post the work "Rusty Has Two Moms"
    When a chapter is set up for "Rusty Has Two Moms"
      And I try to invite the co-author "brenda"
      And I press "Post"
    Then I should see "brenda does not allow others to invite them to be a co-creator."
      And 0 emails should be delivered to "brenda"
    When I press "Preview"
    Then I should see "This is a draft chapter in a posted work. It will be kept unless the work is deleted."
    When I press "Post"
    Then I should see "Chapter was successfully posted."
      And I should see "rusty"
      And I should not see "brenda"

  Scenario: You should be able to add a co-creator to a chapter if they do not allow it, if they are a co-creator of the work.

    Given the user "thegoodmom" allows co-creators
      And I am logged in as "rusty"
      And I set up the draft "Rusty Has Two Moms"
      And I invite the co-author "thegoodmom"
      And I post the work without preview
    Then I should see "Work was successfully posted."
    When the user "thegoodmom" accepts all co-creator requests
      And I view the work "Rusty Has Two Moms"
    Then I should see "rusty, thegoodmom"
    When the user "thegoodmom" disallows co-creators
      And I post a chapter for the work "Rusty Has Two Moms"
    Then I should see "Chapter has been posted!"
      And I follow "Chapter 2"
      And I should see "Chapter by rusty"
      And I follow "Edit Chapter"
    When I check "Add co-creators?"
      And I fill in "pseud_byline" with "thegoodmom"
      And I press "Post"
    Then I should see "Chapter was successfully updated."
      And I follow "Chapter 2"
      And I follow "Edit Chapter"
      And I should see "Remove Me As Chapter Co-Creator"
