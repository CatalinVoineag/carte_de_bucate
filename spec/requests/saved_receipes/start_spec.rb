require 'rails_helper'

RSpec.describe "SavedReceipes::Starts", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/saved_receipes/start/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/saved_receipes/start/create"
      expect(response).to have_http_status(:success)
    end
  end

end
