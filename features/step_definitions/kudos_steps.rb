### GIVEN

Given "a work {string} with {int} kudo(s)" do |title, count|
  step "I start a new session"
  step "basic tags"

  work = FactoryBot.create(:work, title: title)

  count.times do |i|
    user = User.find_by(login: "fan#{i + 1}") ||
           FactoryBot.create(:user, login: "fan#{i + 1}")
    work.kudos.create(user: user)
  end
end

Given "the maximum number of kudos to show is {int}" do |count|
  allow(ArchiveConfig).to receive(:MAX_KUDOS_TO_SHOW).and_return(count)
end

### WHEN

When /^I leave kudos on "([^\"]*)"$/ do |work_title|
  step %{I view the work "#{work_title}"}
  click_button("kudo_submit")
end

When /^a random guest leaves kudos on "([^\"]*)"$/ do |work_title|
  # step %{I view the work "#{work_title}"}
  work = Work.find_by(title: work_title)
  # click_button("kudo_submit")
  ip = "13.13.13"
  Kudo.create(commentable_type: "Work", commentable_id: work.id, ip_address: ip)
end

### THEN

Then /^I should see kudos on every chapter$/ do
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Next Chapter"}
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Entire Work"}
  step %{I should see "myname3 left kudos on this work!"}
end

Then /^I should see kudos on every chapter but the draft$/ do
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Next Chapter"}
  step %{I should see "myname3 left kudos on this work!"}
  step %{I follow "Next Chapter"}
  step %{I should not see "myname3 left kudos on this work!"}
  step %{I follow "Entire Work"}
  step %{I should see "myname3 left kudos on this work!"}
end
