require 'rails_helper'

describe "Complete recipe creation flow", type: :feature, js: true do
  let(:user) { create(:user) }

  before do
    # Set up the current_user to return our test user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    # Visit the start page
    visit start_saved_receipes_path
  end

  it "creates a complete recipe with image, 5 ingredients and 5 instructions" do
    # Step 1: Fill in basic recipe information
    expect(page).to have_content("New receipe")

    # Upload image (create a test image file)
    attach_file 'saved-receipes-start-form-image-field-input', Rails.root.join("tmp", "test_image.jpg"), make_visible: true

    fill_in "Name", with: "Test Recipe from Browser"
    fill_in "Prep time", with: "15 minutes"
    fill_in "Cook time", with: "30 minutes"
    fill_in "Servings", with: "4"
    fill_in "Description", with: "This is a test recipe created through browser automation"

    # Click continue
    click_button "Continue"

    # Step 2: Add 5 ingredients
    expect(page).to have_content("New receipe")
    expect(page).to have_content("Ingredient")

    # Fill in first ingredient (already present)
    within(all('.nested-form-wrapper')[0]) do
      fill_in "Name", with: "Flour"
      fill_in "Quantity", with: "2"
      fill_in "Unit", with: "cups"
      fill_in "Notes", with: "All-purpose flour"
    end

    # Add 4 more ingredients
    ingredient_names = [ "Sugar", "Eggs", "Milk", "Butter" ]
    ingredient_units = [ "cups", "large", "cups", "tablespoons" ]

    ingredient_names.each_with_index do |name, i|
      # Click "Add ingredient" link (styled as button)
      click_link "Add ingredient"

      # Wait a bit for JS to render
      sleep(0.3)

      # Find newly added wrapper (should be last one)
      new_wrapper = all('.nested-form-wrapper').last
      within(new_wrapper) do
        fill_in "Name", with: name
        fill_in "Quantity", with: (i + 1).to_s
        fill_in "Unit", with: ingredient_units[i]
        fill_in "Notes", with: "Notes for #{name}"
      end
    end

    # Click continue to instructions
    click_button "Continue"

    # Step 3: Add 5 instructions
    expect(page).to have_content("Instructions")

    # Fill in first instruction (already present)
    within(all('.nested-form-wrapper')[0]) do
      fill_in "Description", with: "Preheat the oven to 350°F (175°C)."
    end

    # Add 4 more instructions
    instructions = [
      "Mix flour and sugar in a large bowl.",
      "Beat eggs and milk together in a separate bowl.",
      "Combine wet and dry ingredients.",
      "Pour into greased baking pan and bake for 30 minutes."
    ]

    instructions.each_with_index do |instruction, i|
      click_link "Add instruction"
      sleep(0.3)

      new_wrapper = all('.nested-form-wrapper').last
      within(new_wrapper) do
        fill_in "Description", with: instruction
      end
    end

    # Click continue to finish
    click_button "Continue"

    # Should redirect to saved recipes index
    expect(page).to have_current_path(saved_receipes_path)
    expect(page).to have_content("Test Recipe from Browser")

    # Verify the recipe was created correctly
    recipe = MyReceipe.last
    expect(recipe.name).to eq("Test Recipe from Browser")
    expect(recipe.prep_time).to eq("15 minutes")
    expect(recipe.cook_time).to eq("30 minutes")
    expect(recipe.servings).to eq("4")
    expect(recipe.description).to eq("This is a test recipe created through browser automation")
    expect(recipe.status).to eq("published")
    expect(recipe.receipe_ingredients.count).to eq(5)
    expect(recipe.instructions.count).to eq(5)

    # Verify ingredients (note: names are normalized to lowercase)
    ingredient_names = recipe.receipe_ingredients.joins(:ingredient).pluck('ingredients.name')
    expect(ingredient_names).to contain_exactly("flour", "sugar", "eggs", "milk", "butter")

    # Verify instructions (they should be ordered by step)
    instruction_bodies = recipe.instructions.order(:step).pluck(:body)
    expect(instruction_bodies).to include("Preheat the oven to 350°F (175°C).")
    expect(instruction_bodies).to include("Pour into greased baking pan and bake for 30 minutes.")
  end
end
