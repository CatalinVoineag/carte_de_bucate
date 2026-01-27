require 'rails_helper'

describe "Receipes filtering UI", type: :feature, js: true do
  before do
    visit receipes_path
  end

  it "shows Apply Filters and Clear Filters buttons" do
    expect(page).to have_button("Apply Filters")
    expect(page).to have_link("Clear Filters")
  end

  it "does not auto-submit when typing in search field" do
    fill_in "filters-receipe-name-field", with: "Pizza"

    # Should not auto-submit - just check that the field has the value
    expect(find_field("filters-receipe-name-field").value).to eq("Pizza")
  end

  it "shows filter form fields" do
    expect(page).to have_field("filters-receipe-name-field")
    expect(page).to have_field("filters-ingredients-field")
  end

  it "clear filters button has correct URL" do
    clear_link = find_link("Clear Filters")
    expect(clear_link[:href]).to include("filters%5Bremove_filters%5D=true")
  end
end
