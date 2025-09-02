@comments
Feature: Delete a comment
  In order to remove a comment from public view
  As a user
  I want to be able to delete a comment I added
  As an author
  I want to be able to delete a comment a reader added to my work

  Scenario: User deletes a comment they added to a work
    When I am logged in as "author"
      And I post the work "Awesome story"
    When I am logged in as "commenter"
      And I post the comment "Fail comment" on the work "Awesome story"
      And I follow "Delete"
    Then it should take me to the non-JavaScript delete page
    When I press "Yes, delete!"
    Then I should see "Comment deleted."
      And I should not see "Comments:"
      And I should not see a link "Hide Comments (1)"

  @javascript
  Scenario: User deletes a comment they added to a work
    When I am logged in as "author"
      And I post the work "Awesome story"
    When I am logged in as "commenter"
      And I post the comment "Fail comment" on the work "Awesome story"
      And I delete the comment
    Then I should see "Comment deleted."
      And I should not see "Comments:"
      And I should not see a link "Hide Comments (1)"

  @javascript
  Scenario: User deletes a comment they added to a work
    Given the work "Aftermath" by "creator" with guest comments enabled
      And a comment "Fail comment" by "pest" on the work "Aftermath"
      And I am logged in as "pest"
    When I view the work "Aftermath"
    Then I should not see "Fail comment"
    When I display comments
    Then I should see "Fail comment"
    When I follow "Delete"
    Then it should not take me to the non-JavaScript delete page
    When I press "Yes, delete!"
    Then I should see "Comment deleted."
      And I should not see "Comments:"
      And I should not see a link "Hide Comments (1)"


