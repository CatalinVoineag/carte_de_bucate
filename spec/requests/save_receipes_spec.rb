require 'rails_helper'

RSpec.describe "SaveReceipes", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/save_receipes/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/save_receipes/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
