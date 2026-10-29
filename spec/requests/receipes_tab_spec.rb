require "rails_helper"

RSpec.describe "Receipes tab: create, edit and delete", type: :request do
  let(:user) { create(:user, email: "cook@example.com") }
  let(:other) { create(:user, email: "alice@example.com") }
  let(:image) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test_image.jpg"), "image/jpeg") }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def start_params(extra = {})
    {
      image:,
      name: "Test soup",
      prep_time: "10 mins",
      cook_time: "20 mins",
      servings: "Serves 4",
      description: "Warm and simple",
      tags: "Vegetarian, Quick"
    }.merge(extra)
  end

  def publish_receipe(receipe)
    receipe.status = "published"
    receipe.save!(context: :publish)
    ReceipeService::User.save(receipe:, user:)
    receipe
  end

  describe "step 1: details" do
    it "requires an image for a new receipe" do
      post create_receipes_path, params: { receipes_start_form: start_params(image: nil) }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(GlobalReceipe.count).to eq(0)
    end

    it "rejects a file that is not an image" do
      text = Rack::Test::UploadedFile.new(Rails.root.join("Gemfile"), "text/plain")
      post create_receipes_path, params: { receipes_start_form: start_params(image: text) }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(GlobalReceipe.count).to eq(0)
    end

    it "creates a draft authored by the user, with parsed tags" do
      post create_receipes_path, params: { receipes_start_form: start_params }

      receipe = GlobalReceipe.last
      expect(response).to redirect_to(new_receipe_ingredient_path(receipe))
      expect(receipe.author).to eq(user)
      expect(receipe).to be_draft
      expect(receipe.tags).to eq([ "Vegetarian", "Quick" ])
      expect(receipe.image).to be_attached
    end

    it "shows the draft in the Drafts table on the Receipes tab, but not in the grid or My receipes" do
      draft = create(:global_receipe, :draft, author: user, name: "Half finished")

      get receipes_path
      expect(response.body).to include("Half finished")
      expect(response.body).to include(edit_receipe_path(draft))
      expect(response.body).to include(%(data-turbo-method="delete"))

      get saved_receipes_path
      expect(response.body).not_to include("Half finished")
    end

    it "does not ask for the image again when editing" do
      receipe = create(:global_receipe, :draft, :with_image, author: user)

      put update_receipe_path(receipe), params: { receipes_start_form: start_params(image: nil, name: "Renamed") }

      expect(response).to redirect_to(new_receipe_ingredient_path(receipe))
      expect(receipe.reload.name).to eq("Renamed")
      expect(receipe).to be_draft
    end

    it "lets any user edit any receipe, including scraped ones with no author" do
      scraped = create(:global_receipe, :with_image, author: nil, name: "Scraped")

      get edit_receipe_path(scraped)
      expect(response).to have_http_status(:ok)

      put update_receipe_path(scraped), params: { receipes_start_form: start_params(image: nil, name: "Edited by someone") }
      expect(scraped.reload.name).to eq("Edited by someone")
    end
  end

  describe "step 2: ingredients" do
    it "creates new ingredients from named rows" do
      receipe = create(:global_receipe, :draft, author: user, ingredients_count: 0)

      post receipe_ingredients_path(receipe), params: {
        global_receipe: { receipe_ingredients_attributes: {
          "0" => { quantity: "200", unit: "g", notes: "", ingredient_attributes: { name: "Lentils" } }
        } }
      }

      expect(response).to redirect_to(new_receipe_instruction_path(receipe))
      expect(receipe.reload.receipe_ingredients.map { |ri| ri.ingredient.name }).to eq([ "lentils" ])
    end

    it "shows an error for an empty row instead of dropping it" do
      receipe = create(:global_receipe, :draft, author: user, ingredients_count: 0)

      post receipe_ingredients_path(receipe), params: {
        global_receipe: { receipe_ingredients_attributes: {
          "0" => { quantity: "200", unit: "g", ingredient_attributes: { name: "Lentils" } },
          "1" => { quantity: "", unit: "", notes: "", ingredient_attributes: { name: "" } }
        } }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Enter a name for every ingredient")
      expect(receipe.reload.receipe_ingredients).to be_empty
    end

    it "requires at least one ingredient" do
      receipe = create(:global_receipe, :draft, author: user, ingredients_count: 1)
      row = receipe.receipe_ingredients.first

      post receipe_ingredients_path(receipe), params: {
        global_receipe: { receipe_ingredients_attributes: { "0" => { id: row.id, _destroy: "1" } } }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Add at least one ingredient")
    end

    it "does not rename a shared ingredient when a row is changed" do
      flour = Ingredient.create!(name: "flour")
      other_receipe = create(:global_receipe, ingredients_count: 0)
      other_receipe.receipe_ingredients.create!(ingredient: flour, quantity: "2")
      receipe = create(:global_receipe, :draft, author: user, ingredients_count: 0)
      row = receipe.receipe_ingredients.create!(ingredient: flour, quantity: "1")

      post receipe_ingredients_path(receipe), params: {
        global_receipe: { receipe_ingredients_attributes: {
          "0" => { id: row.id, quantity: "1", unit: "", notes: "", ingredient_attributes: { name: "Butter" } }
        } }
      }

      expect(response).to redirect_to(new_receipe_instruction_path(receipe))
      expect(flour.reload.name).to eq("flour")
      expect(row.reload.ingredient.name).to eq("butter")
    end

    it "shows an error when the same ingredient is added twice" do
      receipe = create(:global_receipe, :draft, author: user, ingredients_count: 0)

      post receipe_ingredients_path(receipe), params: {
        global_receipe: { receipe_ingredients_attributes: {
          "0" => { quantity: "1", ingredient_attributes: { name: "salt" } },
          "1" => { quantity: "2", ingredient_attributes: { name: " Salt " } }
        } }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Salt is listed more than once")
    end

    it "removes rows marked for destruction" do
      receipe = create(:global_receipe, :draft, author: user, ingredients_count: 0)
      keep = receipe.receipe_ingredients.create!(ingredient: Ingredient.create!(name: "rice"), quantity: "1")
      drop = receipe.receipe_ingredients.create!(ingredient: Ingredient.create!(name: "oats"), quantity: "1")

      post receipe_ingredients_path(receipe), params: {
        global_receipe: { receipe_ingredients_attributes: {
          "0" => { id: keep.id, quantity: "1", ingredient_attributes: { name: "rice" } },
          "1" => { id: drop.id, _destroy: "1", quantity: "1", ingredient_attributes: { name: "oats" } }
        } }
      }

      expect(receipe.reload.receipe_ingredients.map(&:id)).to eq([ keep.id ])
    end
  end

  describe "step 3: instructions and publishing" do
    it "does not duplicate instructions when the step is submitted again" do
      receipe = create(:global_receipe, :draft, :with_image, author: user, instructions_count: 0)
      first = receipe.instructions.create!(step: 1, body: "Boil")

      post receipe_instructions_path(receipe), params: {
        global_receipe: { instructions_attributes: {
          "0" => { id: first.id, step: 1, body: "Boil the rice" },
          "1" => { step: 2, body: "Serve" }
        } }
      }

      expect(receipe.reload.instructions.count).to eq(2)
      expect(first.reload.body).to eq("Boil the rice")
    end

    it "will not publish a receipe without ingredients" do
      receipe = create(:global_receipe, :draft, :with_image, author: user, ingredients_count: 0)

      post receipe_instructions_path(receipe), params: {
        global_receipe: { instructions_attributes: { "0" => { step: 1, body: "Serve" } } }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(receipe.reload).to be_draft
      expect(MyReceipe.count).to eq(0)
    end

    it "publishes the receipe, and adds it once to the creator's My receipes" do
      receipe = create(:global_receipe, :draft, :with_image, author: user)

      post receipe_instructions_path(receipe), params: {
        global_receipe: { instructions_attributes: { "0" => { step: 1, body: "Serve warm" } } }
      }

      expect(response).to redirect_to(receipe_path(receipe))
      expect(receipe.reload).to be_published
      expect(user.my_receipes.where(global_receipe_id: receipe.id).count).to eq(1)

      post receipe_instructions_path(receipe), params: {
        global_receipe: { instructions_attributes: { "0" => { id: receipe.instructions.first.id, step: 1, body: "Serve warm" } } }
      }
      expect(user.my_receipes.where(global_receipe_id: receipe.id).count).to eq(1)
    end

    it "edits a published receipe and updates every copy" do
      receipe = publish_receipe(create(:global_receipe, :with_image, author: user))
      other_copy = MyReceipe.create!(user: other, name: "old", status: "published", global_receipe: receipe)

      put update_receipe_path(receipe), params: { receipes_start_form: start_params(image: nil, name: "Renamed soup") }

      expect(receipe.reload.name).to eq("Renamed soup")
      expect(other_copy.reload.name).to eq("Renamed soup")
      expect(user.my_receipes.find_by(global_receipe_id: receipe.id).name).to eq("Renamed soup")
      expect(MyReceipe.where(global_receipe_id: receipe.id).count).to eq(2)
    end

    it "syncs the ingredients and instructions of every copy when a published receipe changes" do
      receipe = publish_receipe(create(:global_receipe, :with_image, author: user, ingredients_count: 1))
      other_copy = MyReceipe.create!(user: other, name: "old", status: "published", global_receipe: receipe)
      ReceipeService::SyncCopies.call(receipe:)

      post receipe_ingredients_path(receipe), params: {
        global_receipe: { receipe_ingredients_attributes: {
          "0" => { id: receipe.receipe_ingredients.first.id, quantity: "3", unit: "tbsp", ingredient_attributes: { name: receipe.receipe_ingredients.first.ingredient.name } }
        } }
      }

      expect(other_copy.reload.receipe_ingredients.map(&:quantity)).to eq([ "3" ])
    end
  end

  describe "editing someone else's published receipe" do
    it "does not add it to the editor's My receipes" do
      receipe = create(:global_receipe, :with_image, author: other)

      post receipe_instructions_path(receipe), params: {
        global_receipe: { instructions_attributes: { "0" => { id: receipe.instructions.first.id, step: 1, body: "Edited" } } }
      }

      expect(response).to redirect_to(receipe_path(receipe))
      expect(user.my_receipes.where(global_receipe_id: receipe.id)).to be_empty
    end

    it "lets step 1 of a scraped receipe save even when it lists an ingredient twice" do
      scraped = create(:global_receipe, :with_image, author: nil, ingredients_count: 0)
      flour = Ingredient.create!(name: "flour")
      scraped.receipe_ingredients.create!(ingredient: flour, quantity: "1")
      scraped.receipe_ingredients.create!(ingredient: flour, quantity: "2")

      put update_receipe_path(scraped), params: { receipes_start_form: start_params(image: nil, name: "Fixed name") }

      expect(response).to redirect_to(new_receipe_ingredient_path(scraped))
      expect(scraped.reload.name).to eq("Fixed name")
    end
  end

  describe "delete" do
    it "removes the receipe and every copy in everyone's My receipes" do
      receipe = publish_receipe(create(:global_receipe, :with_image, author: user))
      MyReceipe.create!(user: other, name: "copy", status: "published", global_receipe: receipe)

      delete receipe_path(receipe)

      expect(response).to redirect_to(receipes_path)
      expect(GlobalReceipe.exists?(receipe.id)).to be false
      expect(MyReceipe.where(global_receipe_id: receipe.id)).to be_empty
    end

    it "lets any user delete a scraped receipe" do
      scraped = create(:global_receipe, author: nil)

      expect { delete receipe_path(scraped) }.to change(GlobalReceipe, :count).by(-1)
    end

    it "deletes a draft from the Drafts table" do
      draft = create(:global_receipe, :draft, author: user)

      expect { delete receipe_path(draft) }.to change(GlobalReceipe, :count).by(-1)
    end
  end

  it "has no create, edit or delete routes under My receipes" do
    expect(Rails.application.routes.recognize_path("/saved_receipes/start", method: :get)[:action]).to eq("show")
    expect { Rails.application.routes.recognize_path("/saved_receipes/1/edit", method: :get) }.to raise_error(ActionController::RoutingError)
    expect { Rails.application.routes.recognize_path("/saved_receipes/1", method: :delete) }.to raise_error(ActionController::RoutingError)
  end
end
