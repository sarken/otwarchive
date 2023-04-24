Given "the user {string} has muted the user {string}" do |muter, muted|
  muter = ensure_user(muter)
  muted = ensure_user(muted)
  Mute.create!(muter: muter, muted: muted)
end

Given "there are {int} muted users per page" do |amount|
  allow(Mute).to receive(:per_page).and_return(amount)
end

Given "the maximum number of accounts users can mute is {int}" do |count| 
  allow(ArchiveConfig).to receive(:MAX_MUTED_USERS).and_return(count) 
end

When "I expand the muted comment by {string}" do |user|
  user_id = User.find_by(login: user).id
  find(".comment.user-#{user_id}.muted").click
end

When "I collapse the muted comment by {string}" do |user|
  user_id = User.find_by(login: user).id
  find(".comment.user-#{user_id}.muted").click
end

When "I expand the muted work co-created with {string}" do |user|
  user_id = User.find_by(login: user).id
  find(".work.user-#{user_id}.muted").click
end

When "I collapse the muted work co-created with {string}" do |user|
  user_id = User.find_by(login: user).id
  find(".work.user-#{user_id}.muted").click
end

When "I expand the muted series co-created with {string}" do |user|
  user_id = User.find_by(login: user).id
  find(".series.user-#{user_id}.muted").click
end

When "I collapse the muted series co-created with {string}" do |user|
  user_id = User.find_by(login: user).id
  find(".series.user-#{user_id}.muted").click
end

Then "the user {string} should have a mute for {string}" do |muter, muted|
  muter = User.find_by(login: muter)
  muted = User.find_by(login: muted)
  expect(Mute.find_by(muter: muter, muted: muted)).to be_present
end

Then "the user {string} should not have a mute for {string}" do |muter, muted|
  muter = User.find_by(login: muter)
  muted = User.find_by(login: muted)
  expect(Mute.find_by(muter: muter, muted: muted)).to be_blank
end
