# frozen_string_literal: true

require 'spec_helper'

describe KudosController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "create" do
    context "when work is public" do
      let(:user) { create(:user) }
      let!(:work) { create(:posted_work, authors: [user.pseuds.first]) }

      context "when kudos are given from work" do
        it "redirects to work with notice" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          it_redirects_to_with_comment_notice(work_path(work), "Thank you for leaving kudos!")
        end
      end

      context "when kudos are given from chapter" do
        it "redirects to chapter with notice" do
          post :create, params: { kudo: { commentable_id: work.chapters.first.id, commentable_type: "Chapter" } }
          it_redirects_to_with_comment_notice(work_chapter_path(work, work.chapters.first), "Thank you for leaving kudos!")
        end
      end

      context "when kudos giver is creator of work" do
        before do
          fake_login_known_user(user)
        end

        it "redirects with an error" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          expect(response).to have_http_status :redirect
          expect(flash[:comment_error]).to include("You can't leave kudos on your own work.")
        end

        context "with format: :js" do
          it "returns an error in JSON format" do
            post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
            expect(JSON.parse(response.body)["errors"]["cannot_be_author"]).to include("^You can't leave kudos on your own work.")
          end
        end
      end
    end

    context "when work does not exist" do
      it "redirects to root path with error" do
        post :create, params: { kudo: { commentable_id: 000, commentable_type: "Work" } }
        it_redirects_to_with_comment_error(root_path, "We couldn't save your kudos, sorry!")
      end

      context "with format: :js" do
        it "returns an error in JSON format" do
          post :create, params: { kudo: { commentable_id: 000, commentable_type: "Work" }, format: :js }
          expect(JSON.parse(response.body)["errors"]["no_commentable"]).to include("^What did you want to leave kudos on?")
        end
      end
    end

    context "when work is restricted" do
      let!(:work) { create(:restricted_work) }

      it "redirects with an error" do
        post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
        expect(response).to have_http_status :redirect
        expect(flash[:comment_error]).to include("You can't leave guest kudos on a restricted work.")
      end

      context "with format: :js" do
        it "returns an error in JSON format" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
          expect(JSON.parse(response.body)["errors"]["guest_on_restricted"]).to include("^You can't leave guest kudos on a restricted work.")
        end
      end
    end
  end
end
