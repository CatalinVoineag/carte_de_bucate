require "rails_helper"

RSpec.describe ReceipeIngredient, type: :model do
  let(:user) { create(:user) }

  it "creates a new ingredient in the database when the name is new" do
    receipe = create(:my_receipe, user:)
    row = receipe.receipe_ingredients.build(quantity: "1")
    row.ingredient_attributes = { name: "  Saffron " }

    expect(row.ingredient.name).to eq("saffron")
    expect(Ingredient.where(name: "saffron").count).to eq(1)
  end

  it "does not rename an ingredient that other receipes use" do
    flour = Ingredient.create!(name: "flour")
    other = create(:global_receipe, ingredients_count: 0)
    other.receipe_ingredients.create!(ingredient: flour, quantity: "2")
    mine = create(:my_receipe, user:)
    row = mine.receipe_ingredients.create!(ingredient: flour, quantity: "1")

    row.ingredient_attributes = { name: "Butter" }
    row.save!

    expect(flour.reload.name).to eq("flour")
    expect(row.reload.ingredient.name).to eq("butter")
    expect(other.receipe_ingredients.first.ingredient.name).to eq("flour")
  end

  it "reuses an existing ingredient when renamed to its name" do
    sugar = Ingredient.create!(name: "sugar")
    flour = Ingredient.create!(name: "flour")
    mine = create(:my_receipe, user:)
    row = mine.receipe_ingredients.create!(ingredient: flour, quantity: "1")

    expect { row.ingredient_attributes = { name: "sugar" } }.not_to change(Ingredient, :count)
    expect(row.ingredient).to eq(sugar)
  end

  it "leaves the ingredient empty when the name is blank" do
    mine = create(:my_receipe, user:)
    row = mine.receipe_ingredients.create!(ingredient: Ingredient.create!(name: "rice"), quantity: "1")

    row.ingredient_attributes = { name: " " }
    expect(row.ingredient).to be_nil
  end
end
