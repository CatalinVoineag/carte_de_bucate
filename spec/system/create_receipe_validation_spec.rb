require "rails_helper"

describe "Create receipe validation and publishing", type: :feature, js: true do
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  it "shows the error summary when step 1 is submitted empty" do
    visit start_receipes_path
    click_button "Continue"

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Select an image")
    expect(page).to have_content("Enter a name for the receipe")
  end

  it "publishes a receipe in the Receipes tab, and it is saved to My receipes" do
    visit start_receipes_path
    attach_file "receipes-start-form-image-field-input", file_fixture("test_image.jpg"), make_visible: true
    fill_in "Name", with: "Browser soup"
    fill_in "Prep time", with: "5 mins"
    fill_in "Cook time", with: "10 mins"
    fill_in "Servings", with: "2"
    fill_in "Tags (optional)", with: "Quick, Vegetarian"
    fill_in "Description", with: "Simple soup"
    click_button "Continue"
    expect(page).to have_content("Step 2 of 3")

    within(all(".nested-form-wrapper")[0]) do
      fill_in "Name", with: "Stock"
      fill_in "Quantity", with: "1/2"
      fill_in "Unit", with: "litre"
    end
    click_button "Add ingredient"
    within(all(".nested-form-wrapper").last) do
      fill_in "Name", with: "Carrot"
      fill_in "Quantity", with: "2"
    end
    click_button "Add ingredient"
    within(all(".nested-form-wrapper").last) do
      fill_in "Name", with: "Parsley"
    end
    within(all(".nested-form-wrapper")[1]) do
      find("button[data-action='nested-form#remove']").click
    end
    expect(page).to have_css(".nested-form-wrapper", count: 2, visible: true)
    click_button "Continue"
    expect(page).to have_content("Step 3 of 3")

    within(all(".nested-form-wrapper")[0]) do
      fill_in "Description", with: "Heat the stock"
    end
    click_button "Continue"

    expect(page).to have_content("Receipe published")
    expect(page).to have_content("Browser soup")

    visit receipes_path
    expect(page).to have_content("Browser soup")

    click_link "Browser soup"
    expect(page).to have_button("Remove from my receipes")
    expect(page).not_to have_button("Save to my receipes")
  end

  it "keeps the ingredient list when step 2 has errors" do
    visit start_receipes_path
    attach_file "receipes-start-form-image-field-input", file_fixture("test_image.jpg"), make_visible: true
    fill_in "Name", with: "Empty soup"
    fill_in "Prep time", with: "5 mins"
    fill_in "Cook time", with: "10 mins"
    fill_in "Servings", with: "2"
    fill_in "Description", with: "Nothing in it"
    click_button "Continue"
    expect(page).to have_content("Step 2 of 3")

    within(all(".nested-form-wrapper")[0]) do
      fill_in "Quantity", with: "2"
    end
    click_button "Continue"

    expect(page).to have_content("Enter a name for every ingredient")
  end
end
