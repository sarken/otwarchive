# frozen_string_literal: true
require "spec_helper"

describe HomeController do
  describe "index" do
    context "with hide_banner params" do
      it "sets hide_banner cookie" do
        get :index, params: { hide_banner: true }
        expect(cookies[:hide_banner]).to eq("true")
      end
    end
  end
end
