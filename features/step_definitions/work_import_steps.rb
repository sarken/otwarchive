require "webmock/cucumber"

def content_fields
  {
    title: "Detected Title", summary: "Detected summary", fandoms: "Detected Fandom", warnings: "Underage Sex",
    characters: "Detected 1, Detected 2", rating: "Explicit", relationships: "Detected 1/Detected 2",
    categories: "F/F", freeform: "Detected tag 1, Detected tag 2", external_author_name: "Detected Author",
    external_author_email: "detected@foo.com", notes: "This is a <i>content note</i>.",
    date: "2002-01-12", chapter_title: "Detected chapter title"
  }
end

# Let the test get at external sites, but stub out anything containing certain keywords
def mock_external
  WebMock.allow_net_connect!

  WebMock.stub_request(:any, /import-site-with-tags/).
    to_return(status: 200,
              body:
                "Title: #{content_fields[:title]}
Summary:  #{content_fields[:summary]}
Date: #{content_fields[:date]}
Fandom:  #{content_fields[:fandoms]}
Rating: #{content_fields[:rating]}
Warnings:  #{content_fields[:warnings]}
Characters:  #{content_fields[:characters]}
Pairings:  #{content_fields[:relationships]}
Category:  #{content_fields[:categories]}
Tags:  #{content_fields[:freeform]}
Author's notes:  #{content_fields[:notes]}

stubbed response", headers: {})

  WebMock.stub_request(:any, /import-site-without-tags/).
    to_return(status: 200,
              body: "stubbed response",
              headers: {})

  WebMock.stub_request(:any, /second-import-site-without-tags/).
    to_return(status: 200,
              body: "second stubbed response",
              headers: {})

  WebMock.stub_request(:any, /no-content/).
    to_return(status: 200,
              body: "",
              headers: {})

  WebMock.stub_request(:any, /bar/)
    .to_return(status: 404, headers: {})

  WebMock.stub_request(:any, /second-import-site-with-tags/)
    .to_return(status: 200,
               headers: {},
               body: <<~BODY
                 <html><head>
                 <title>Huddling</title></head>
                 <body>

                 <!-- STORYINFO
                 title: Huddling
                 fandom: OTW RPF
                 date: 2010-01-11
                 summary: "Are we in a test?" Tester asked.
                 wordcount: 12,034
                 -->


                 <p><strong>Huddling</strong></p>
                 <p>by an_author for the <a href="http://example.com">otwarchive testing meme</a>.</p>

                 <p>"What is this place?" orphan_account asked.</p>

                 <p>"I&mdash;don't know," Tester said.</p>

                 <p>= End =</p>

                 </body></html>
               BODY
              )
end

Given "I set up mock websites for importing" do
  mock_external
end

Given /^I set up importing( with a mock website)?( as an archivist)?$/ do |mock, is_archivist|
  unless mock.blank?
    mock_external
  end
  step %{basic languages}
  step %{basic tags}
  step %{all warnings exist}
  if is_archivist.blank?
    step %{I am logged in as a random user}
  else
    step %{I have an archivist "archivist"}
    step %{I am logged in as "archivist"}
  end
  step %{I go to the import page}
end

When /^I start importing "(.*)"( with a mock website)?( as an archivist)?$/ do |url, mock, is_archivist|
  step %{I set up importing#{mock}#{is_archivist}}
  step %{I fill in "urls" with "#{url}"}
  step %{I select "English" from "Choose a language"}
end

When "I import the mock work {string} by {string} with email {string} and by {string} with email {string}" do |url, creator_name, creator_email, cocreator_name, cocreator_email|
  step(%{I start importing "#{url}" with a mock website as an archivist})
  step(%{I check "Import for others ONLY with permission"})
  step(%{I fill in "external_author_name" with "#{creator_name}"})
  step(%{I fill in "external_author_email" with "#{creator_email}"})
  step(%{I fill in "external_coauthor_name" with "#{cocreator_name}"})
  step(%{I fill in "external_coauthor_email" with "#{cocreator_email}"})
  step(%{I check "Post without previewing"})
  step(%{I press "Import"})
end

When /^I import "(.*)"( with a mock website)?$/ do |url, mock|
  step %{I start importing "#{url}"#{mock}}
  step %{I press "Import"}
end

When /^I import the urls with mock websites( as chapters)?( without preview)?$/ do |chapters, no_preview, urls|
  step %{I set up importing with a mock website}
  step %{I fill in "urls" with "#{urls}"}
  step %{I select "English" from "Choose a language"}
  if chapters
    step %{I choose "import_multiple_chapters"}
  end
  if no_preview
    step %{I check "post_without_preview"}
  end
  step %{I press "Import"}
end
