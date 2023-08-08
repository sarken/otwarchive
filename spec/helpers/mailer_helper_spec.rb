require "spec_helper"

describe MailerHelper do
  let(:work) { create(:work) }
  let(:chapter) { create(:chapter) }
  let(:series) { create(:series) }

  describe "style_creation_link" do
    it "nests red link inside bold inside italics" do
      expect(style_creation_link(work.title, work_url(work))).to eq("<i><b><a style=\"color:#990000\" href=\"#{work_url(work)}\">#{work.title}</a></b></i>")
    end
  end

  describe "#creation_title" do
    context "when creation is a series" do
      it "returns the series title" do
        expect(creation_title(series)).to eq(series.title)
      end
    end

    context "when creation is a work" do
      it "returns the work title" do
        expect(creation_title(work)).to eq(work.title)
      end
    end

    context "when creation is a chapter" do
      it "returns the work title with the chapter number" do
        expect(creation_title(chapter)).to eq("Chapter #{chapter.position} of #{work.title}")
      end
    end
  end

  describe "#creation_link_with_word_count" do
    context "when creation is a chapter" do
      it "returns hyperlinked full_chapter_title and parenthetical word count" do
        expect(creation_link_with_word_count(chapter, chapter_url(chapter))).to eq("<i><b><a style=\"color:#990000\" href=\"#{chapter_url(chapter)}\">#{chapter.full_chapter_title}</a></b></i> (#{chapter.word_count} words)")
      end
    end

    context "when creation is a series" do
      it "returns hyperlinked series title and parenthetical word count" do
        expect(creation_link_with_word_count(series, series_url(series))).to eq("<i><b><a style=\"color:#990000\" href=\"#{series_url(series)}\">#{series.title}</a></b></i> (#{series.word_count} words)")
      end
    end

    context "when creation is a work" do
      it "returns hyperlinked work title and parenthetical word count" do
        expect(creation_link_with_word_count(work, work_url(work))).to eq("<i><b><a style=\"color:#990000\" href=\"#{work_url(work)}\">#{work.title}</a></b></i> (#{work.word_count} words)")
      end
    end
  end

  describe "#creation_title_with_word_count" do
    context "when creation is a chapter" do
      it "returns full_chapter_title and parenthetical word count" do
        expect(creation_title_with_word_count(chapter)).to eq("\"#{chapter.full_chapter_title}\" (#{chapter.word_count} words)")
      end
    end

    context "when creation is a series" do
      it "returns series title and parenthetical word count" do
        expect(creation_title_with_word_count(series)).to eq("\"#{series.title}\" (#{series.word_count} words)")
      end
    end

    context "when creation is a work" do
      it "returns work title and parenthetical word count" do
        expect(creation_title_with_word_count(work)).to eq("\"#{work.title}\" (#{work.word_count} words)")
      end
    end
  end

  describe "#work_metadata_label" do
    it "appends the metadata indicator to a string" do
      expect(work_metadata_label("Text")).to eq("Text: ")
    end
  end

  describe "#work_tag_metadata" do
    it "returns nil when given an unpermitted tag_klass" do
      expect(style_work_tag_metadata("Media", "tag")).to be_nil
    end

    it "returns nil when given a blank tag_string" do
      expect(style_work_tag_metadata("Fandom", "")).to be_nil
    end

    it "returns nil when given nil as a tag_string" do
      expect(style_work_tag_metadata("Fandom", nil)).to be_nil
    end

    {
      "Fandom" => ["Fandom: ", "Fandoms: "],
      "Rating" => ["Rating: ", "Ratings: "],
      "ArchiveWarning" => ["Warning: ", "Warnings: "],
      "Relationship" => ["Relationship: ", "Relationships: "],
      "Character" => ["Character: ", "Characters: "],
      "Freeform" => ["Additional Tag: ", "Additional Tags: "]
    }.each_pair do |klass, labels|
      context "when given one #{klass.underscore.humanize.downcase.singularize}" do
        let(:string) { "tag 1" }

        it "returns \"#{labels[0]}\" followed by the tag name" do
          expect(work_tag_metadata(klass, string)).to eq("#{labels[0]}#{string}")
        end
      end

      context "when given multiple #{klass.underscore.humanize.downcase.pluralize}" do
        let(:string) { "tag 1, tag 2" }

        it "returns \"#{labels[1]}\" followed by a comma-separated list of tag names" do
          expect(work_tag_metadata(klass, string)).to eq("#{labels[1]}#{string}")
        end
      end
    end
  end

  describe "#style_work_tag_metadata" do
    it "returns nil when given an unpermitted tag_klass" do
      expect(style_work_tag_metadata("Media", "tag")).to be_nil
    end

    it "returns nil when given a blank tag_string" do
      expect(style_work_tag_metadata("Fandom", "")).to be_nil
    end

    it "returns nil when given nil as a tag_string" do
      expect(style_work_tag_metadata("Fandom", nil)).to be_nil
    end

    context "when given one fandom" do
      let(:fandom) { create(:fandom) }
      let(:string) { fandom.name }

      it "returns \"Fandom: \" styled bold and red followed by a link to the fandom" do
        label = "<b style=\"color:#990000\">Fandom: </b>"
        link = link_to(fandom.name, fandom_url(fandom), style: "color:#990000")
        expect(style_work_tag_metadata("Fandom", string)).to eq("#{label}#{link}")
      end
    end

    context "when given multiple fandoms" do
      let(:fandom1) { create(:fandom) }
      let(:fandom2) { create(:fandom) }
      let(:string) { "#{fandom1.name}, #{fandom2.name}" }

      it "returns \"Fandoms: \" styled bold and red followed by links to the fandoms combined using to_sentence" do
        label = "<b style=\"color:#990000\">Fandoms: </b>"
        link1 = link_to(fandom1.name, fandom_url(fandom1), style: "color:#990000")
        link2 = link_to(fandom2.name, fandom_url(fandom2), style: "color:#990000")
        list = "#{link1} and #{link2}"
        expect(style_work_tag_metadata("Fandom", string)).to eq("#{label}#{list}")
      end
    end

    {
      "Rating" => ["Rating:", "Ratings:"],
      "ArchiveWarning" => ["Warning:", "Warnings:"],
      "Relationship" => ["Relationship:", "Relationships:"],
      "Character" => ["Character:", "Characters:"],
      "Freeform" => ["Additional Tag:", "Additional Tags:"]
    }.each_pair do |klass, labels|
      context "when given one #{klass.underscore.humanize.downcase.singularize}" do
        let(:string) { "tag 1" }

        it "returns \"#{labels[0]} \" styled bold and red followed by the tag name" do
          label = "<b style=\"color:#990000\">#{labels[0]} </b>"
          expect(style_work_tag_metadata(klass, string)).to eq("#{label}#{string}")
        end
      end

      context "when given multiple #{klass.underscore.humanize.downcase.pluralize}" do
        let(:string) { "tag 1, tag 2" }

        it "returns \"#{labels[1]} \" styled bold and red followed by a comma-separated list of tag names" do
          label = "<b style=\"color:#990000\">#{labels[1]} </b>"
          expect(style_work_tag_metadata(klass, string)).to eq("#{label}#{string}")
        end
      end
    end
  end
end
