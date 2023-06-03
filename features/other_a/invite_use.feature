Feature: invitations
In order to join the archive
As an unregistered user
I want to use an invitation to create an account

  Scenario: user attempts to use an invitation

  Given account creation is enabled
    And account creation requires an invitation
    And I am a visitor
  When I use an invitation to sign up
  Then I should see "Create Account"

  Scenario: user attempts to use an already redeemed invitation

  Given account creation is enabled
    And account creation requires an invitation
    And I am a visitor
  When I use an already used invitation to sign up
  Then I should see "This invitation has already been used to create an account"

  Scenario: I visit the invitations page for a non-existent user

  Given I am a visitor
    And I go to SOME_USER's invitations page
  Then I should be on the login page
    And I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
    When I am logged in as "Scott" with password "password"
    And I go to SOME_USER2's invitations page
  Then I should be on Scott's user page
    And I should see "Sorry, you don't have permission to access the page you were trying to reach."

  Scenario: The correct link is displayed for an invitation used to create an account that still exists

  Given "inviter" has invited "newbie"
  When I am logged in as "inviter"
    And I go to inviter's manage invitations page
  Then I should see "newbie"
  When I follow "newbie"
  Then I should be on newbie's user page
  When I am logged in as a "policy_and_abuse" admin
    And I go to inviter's manage invitations page
  Then I should see "newbie"
  When I follow "newbie"
  Then I should be on the user administration page for "newbie"

  Scenario: The correct information is displayed for an invitation used to create an account that has been deleted

  Given "inviter" has invited "deleted"
    And I am logged in as "deleted"
    And "deleted" deletes their account
  When I am logged in as "inviter"
    And I go to inviter's manage invitations page
  Then I should not see "(Deleted)"
  When I am logged in as a "policy_and_abuse" admin
    And I go to inviter's manage invitations page
  Then I should see "(Deleted)"
