require "rails_helper"

RSpec.describe Receipe, type: :model do
  describe "draft validations" do
    it "allows a draft with only a name" do
      expect(GlobalReceipe.new(name: "Soup", status: "draft")).to be_valid(:draft)
    end

    it "requires a name in the wizard" do
      receipe = GlobalReceipe.new(name: "", status: "draft")
      expect(receipe).not_to be_valid(:draft)
      expect(receipe.errors[:name]).to be_present
    end

    it "does not require a name for ordinary saves, so scraped data keeps saving" do
      expect(GlobalReceipe.new(name: "", status: "published")).to be_valid
    end
  end

  describe "publish validations" do
    it "requires details, ingredients, instructions and an image" do
      receipe = GlobalReceipe.new(name: "Soup", status: "published")
      expect(receipe.valid?(:publish)).to be false
      expect(receipe.errors[:description]).to be_present
      expect(receipe.errors[:prep_time]).to be_present
      expect(receipe.errors[:base]).to include("Add at least one ingredient")
      expect(receipe.errors[:base]).to include("Add at least one instruction")
      expect(receipe.errors[:image]).to be_present
    end

    it "passes when the receipe is complete" do
      receipe = create(:global_receipe, :with_image)
      expect(receipe.valid?(:publish)).to be true
    end
  end

  describe "saving existing receipes" do
    it "does not apply wizard rules to ordinary saves" do
      receipe = create(:global_receipe, ingredients_count: 0)
      flour = Ingredient.create!(name: "flour")
      receipe.receipe_ingredients.create!(ingredient: flour, quantity: "1", notes: "x" * 300)
      receipe.receipe_ingredients.create!(ingredient: flour, quantity: "2")

      expect(receipe.valid?).to be true
    end
  end

  describe "ingredient rules" do
    it "rejects the same ingredient twice in the wizard" do
      flour = Ingredient.create!(name: "flour")
      receipe = build(:global_receipe, status: "draft", ingredients_count: 0)
      receipe.receipe_ingredients.build(ingredient: flour, quantity: "1")
      receipe.receipe_ingredients.build(ingredient: flour, quantity: "2")

      expect(receipe.valid?(:ingredients)).to be false
      expect(receipe.errors[:base]).to include("Flour is listed more than once")
    end
  end
end
