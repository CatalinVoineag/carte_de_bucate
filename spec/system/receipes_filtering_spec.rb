require 'rails_helper'

describe "Receipes filtering functionality", type: :feature, js: true do
  before do
    visit receipes_path
  end

  it "displays Apply Filters and Clear Filters buttons" do
    expect(page).to have_button("Apply Filters")
    expect(page).to have_link("Clear Filters")
  end

  it "does not auto-submit when typing in search field" do
    fill_in "filters-receipe-name-field", with: "Pizza"

    # Should not auto-submit - form should stay on page
    expect(page).to have_field("filters-receipe-name-field")
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

  it "apply filters button exists" do
    expect(page).to have_button("Apply Filters")
  end

  it "buttons are properly styled" do
    expect(page).to have_css(".govuk-button")
    expect(page).to have_css(".govuk-button--secondary")
  end
end
