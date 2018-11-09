@works
Feature: Parsing HTML

  # tests for parsing only are in spec/lib/html_cleaner_spec.rb

  Scenario: Editing a work and saving it without changes should preserve the same content 
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    This is paragraph 1.

    This is paragraph 2.
    """
    And I press "Preview"
  Then I should see "Preview"
    And I should see the text with tags "<p>This is paragraph 1.</p><p>This is paragraph 2.</p>"
  When I press "Post"
   And I follow "Edit"
   And I press "Preview"
  Then I should see the text with tags "<p>This is paragraph 1.</p><p>This is paragraph 2.</p>"
  
  Scenario: HTML Parser should kick in  
  When I am logged in as "newbie" with password "password"
    And I set up the draft "My Awesome Story"
    And I fill in "content" with 
    """
    A paragraph

    Another paragraph.
    """
    And I press "Preview"
  Then I should see "Preview"
    And I should see the text with tags "<p>A paragraph</p><p>Another paragraph.</p>" 

  Scenario: Can't use classes in comments
  Given the work "Generic Work"
    And I am logged in as "commenter"
    And I view the work "Generic Work"
  When I fill in "Comment" with "<p class='strip me'>Hi there!</p>"
    And I press "Comment"
  Then I should see "Comment created!"
  When I follow "Edit"
  Then the "Comment" field should not contain "strip me"

  Scenario: Can use classes in works
  Given I am logged in as a random user
    And I set up the draft "Classy Work"
  When I fill in "content" with "<p class='keep me'>You better work</p>"
    And I press "Post Without Preview"
    And I follow "Edit"
  Then the "content" field should contain "keep me"
