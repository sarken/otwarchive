Feature:
  Managing assignments in a gift exchange.

Background: 
  Given a canonical fandom "DS9"
    And a canonical fandom "TOS"
    And a canonical fandom "VOY"
    And I have set up the simple fandom-based gift exchange "xchange"
    And "oTOS_rDS9" offers "TOS" and requests "DS9" in the simple fandom-based gift exchange "xchange"
    And "oDS9_rTOS" offers "DS9" and requests "TOS" in the simple fandom-based gift exchange "xchange"

Scenario: Assignments cannot be sent if there is a participant without a recipient.
  When "oVOY_rTOS" offers "VOY" and requests "TOS" in the simple fandom-based gift exchange "xchange"
    And I am logged in as "mod1"
    And I have generated matches for "xchange"
    And I go to "xchange" gift exchange matching page
    And I follow "Send Assignments"
  Then I should see "Some participants still aren't assigned. Please either delete them or match them to a placeholder before sending out assignments."

Scenario: Assignments can be sent if there is a participant without a giver. The participant will be listed on the Pinch Hits page.
  When "oDS9_rVOY" offers "DS9" and requests "VOY" in the simple fandom-based gift exchange "xchange"
    And I am logged in as "mod1"
    And I have generated matches for "xchange"
    And I go to "xchange" gift exchange matching page
  Then show me the page
    And I follow "Generate Potential Matches"
  Then show me the page
  Then I should not see "Some participants still aren't assigned. Please either delete them or match them to a placeholder before sending out assignments."
