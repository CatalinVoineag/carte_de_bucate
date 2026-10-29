require "rails_helper"

RSpec.describe Ingredient, type: :model do
  it "stores names lowercased and trimmed" do
    expect(Ingredient.create!(name: "  Salt ").name).to eq("salt")
  end

  it "accepts long names so the scraper keeps working" do
    expect(Ingredient.new(name: "a" * 300)).to be_valid
  end
end
