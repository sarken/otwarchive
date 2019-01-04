@collections @promptmemes @giftexchanges @challenges @works @gifts

Feature: Notification emails for individually revealed collection items
  When a moderator reveals an individual collection item, the relevant
  notification emails should be sent.

Scenario: Notifying a recipient when a gift work for them is revealed
  Given the unrevealed collection "Unrevealed Collection"
    And the user "recip" exists and is activated
  When I am logged in as a random user
    And I post the work "Surprise Present" to the collection "Unrevealed Collection" as a gift for "recip"
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Surprise Present" in the collection "Unrevealed Collection"
  Then "recip" should be notified by email about their gift "Surprise Present"

Scenario: Notifying a user when a response to their prompt is revealed
  Given basic tags
    And the unrevealed prompt meme "Prompt Meme" with 1 sign-up
  When I am logged in as a random user
    And I claim a prompt from "Prompt Meme"
    And I fulfill my claim
  Then 0 emails should be delivered
  When I am logged in as the owner of "Prompt Meme"
    And I view the approved collection items page for "Prompt Meme"
    # Title is defined in challenge_promptmeme_steps
    And I reveal the work "Fulfilled Story" in the collection "Prompt Meme"
  Then the prompter should be notified by email about the work "Fulfilled Story"

Scenario: Notifying a user when a work inspired by one of their works is
revealed
  Given the unrevealed collection "Unrevealed Collection"
    And an inspiring parent work has been posted
  When I am logged in as a random user
    And I set up the draft "Unauthorized Sequel" to the collection "Unrevealed Collection"
    # Title is defined in work_related_steps
    And I list the work "Parent Work" as inspiration
    And I post the work without preview
  Then 0 emails should be delivered
  When I am logged in as the owner of "Unrevealed Collection"
    And I view the approved collection items page for "Unrevealed Collection"
    And I reveal the work "Unauthorized Sequel" in the collection "Unrevealed Collection"
  Then 1 email should be delivered
