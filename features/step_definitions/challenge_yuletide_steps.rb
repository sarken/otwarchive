Given /^I have Yuletide challenge tags set ?up$/ do
  step "I have standard challenge tags setup"
  step %{I add the fandom tags "Starsky & Hutch, Tiny fandom, Care Bears, Yuletide Hippos RPF, Unoffered, Unrequested" to the tag set "Standard Challenge Tags"}
  step %{a canonical fandom "Starsky & Hutch"}
  step %{a canonical fandom "Tiny fandom"}
  step %{a canonical fandom "Care Bears"}
  step %{a canonical fandom "Yuletide Hippos RPF"}
  step %{a canonical fandom "Unoffered"}
  step %{a canonical fandom "Unrequested"}
end

When /^"([^"]*)" posts the fulfilling draft "([^"]*)" in "([^"]*)"$/ do |name, title, fandom|
  step %{I am logged in as "#{name}"}
  step %{I go to #{name}'s user page}
  step %{I follow "Assignments"}
  step %{I follow "Fulfill"}
  step %{I fill in "Work Title" with "#{title}"}
  step %{I fill in "Fandoms" with "#{fandom}"}
  step %{I select "Not Rated" from "Rating"}
  step %{I check "No Archive Warnings Apply"}
  step %{I fill in "content" with "This is an exciting story about #{fandom}"}
  step %{I press "Preview"}
end

When /^"([^"]*)" posts the fulfilling story "([^"]*)" in "([^"]*)"$/ do |name, title, fandom|
  step %{"#{name}" posts the fulfilling draft "#{title}" in "#{fandom}"}
  step %{I press "Post"}
  step %{I should see "Work was successfully posted"}
  step %{I should see "For myname"}
  step %{I should see "Collections:"}
  step %{I should see "Yuletide" within ".meta"}
  step %{I should see "Anonymous"}
end