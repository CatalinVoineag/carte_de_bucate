require 'rails_helper'

RSpec.describe "SavedReceipes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/saved_receipes/index"
      expect(response).to have_http_status(:success)
    end
  end

end
