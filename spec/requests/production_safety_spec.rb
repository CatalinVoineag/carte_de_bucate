require "rails_helper"

# Behaviour that existing production data relies on
RSpec.describe "Production safety", type: :request do
  let(:user) { create(:user) }
  let(:other) { create(:user, email: "other@example.com") }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  it "still lets the scraper create receipes with long ingredient names and step 0" do
    receipe = GlobalReceipe.create!(
      name: "Scraped", status: :published,
      instructions_attributes: { "0" => { step: 0, body: "Boil" } },
      receipe_ingredients_attributes: { "0" => { quantity: "1", ingredient_attributes: { name: "very " * 40 } } }
    )

    expect(receipe.receipe_ingredients.first.ingredient.name.length).to be > 100
  end

  it "keeps existing ingredient names with inner spaces matching" do
    existing = Ingredient.create!(name: "black  pepper")
    row = ReceipeIngredient.new
    row.ingredient_attributes = { name: "Black  Pepper" }

    expect(row.ingredient).to eq(existing)
  end

  it "saves a copy of a scraped receipe even when it has duplicate ingredient names" do
    global = create(:global_receipe, ingredients_count: 0)
    flour = Ingredient.create!(name: "flour")
    global.receipe_ingredients.create!(ingredient: flour, quantity: "1")
    global.receipe_ingredients.create!(ingredient: flour, quantity: "2")

    expect(ReceipeService::User.save(receipe: global, user:)).to be true
  end

  it "saves a copy of a scraped receipe with a long description and no image" do
    global = create(:global_receipe, description: "x" * 3000, prep_time: nil, cook_time: nil, servings: nil)

    expect(ReceipeService::User.save(receipe: global, user:)).to be true
  end

  it "saves a receipe whose image file is missing from storage" do
    global = create(:global_receipe, :with_image)
    ActiveStorage::Blob.service.delete(global.image.blob.key)

    expect(ReceipeService::User.save(receipe: global, user:)).to be true
  end

  it "deletes the copies when the public receipe is deleted" do
    global = create(:global_receipe, :with_image)
    copy = ReceipeService::User.save(receipe: global, user:) && MyReceipe.find_by(global_receipe_id: global.id)

    ReceipeService::DestroyReceipe.call(receipe: global)

    expect(MyReceipe.exists?(copy.id)).to be false
  end

  it "keeps a copy when another user removes theirs" do
    global = create(:global_receipe, :with_image)
    ReceipeService::User.save(receipe: global, user:)
    other_copy = MyReceipe.create!(user: other, name: "Theirs", status: "published", global_receipe: global)

    ReceipeService::User.remove(receipe: global, user:)

    expect(other_copy.reload.global_receipe_id).to eq(global.id)
    expect(global.reload.image).to be_attached
  end

  it "can delete a public receipe other users have saved" do
    global = create(:global_receipe)
    saved = MyReceipe.create!(user: other, name: "Saved", status: "published", global_receipe: global)

    expect { ReceipeService::DestroyReceipe.call(receipe: global) }.not_to raise_error
    expect(MyReceipe.exists?(saved.id)).to be false
  end

  it "shows a receipe page when there is no user yet" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
    global = create(:global_receipe)

    get receipe_path(global)
    expect(response).to have_http_status(:ok)
  end

  it "does not crash on .json URLs" do
    global = create(:global_receipe)

    get "/receipes/#{global.id}.json"
    expect(response).to have_http_status(:not_acceptable)
  end

  it "does not offer an empty tag in the filters" do
    create(:global_receipe, tags: nil)
    create(:global_receipe, tags: [ "Quick" ])

    get receipes_path
    tag_checkboxes = response.body.scan(/<input[^>]*type="checkbox"[^>]*name="filters\[tags\]\[\]"[^>]*>/)
    expect(tag_checkboxes.map { |input| input[/value="([^"]*)"/, 1] }).to eq([ "Quick" ])
  end
end
