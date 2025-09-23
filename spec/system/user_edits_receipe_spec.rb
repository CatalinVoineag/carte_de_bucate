require 'rails_helper'

describe "user edits receipe", type: :feature, js: true do
  it "signs me in" do
    receipe = create(:receipe, :with_ingredients)
    visit edit_receipe_path(receipe)

    expect(page).to have_content "Editing receipe"
    expect(page).to have_field('receipe_name', with: receipe.name)
    expect(page).to have_field('Description', with: receipe.description)
    expect(page).to have_field('Instruction', with: receipe.instructions)

    within all('.nested-form-wrapper')[0] do
      first_ingredient = receipe.ingredients.first
      first_receipe_ingredient = receipe.receipe_ingredients.first

      expect(page).to have_field('Name', with: first_ingredient.name)
      expect(page).to have_field('Quantity', with: first_receipe_ingredient.quantity)
      expect(page).to have_field('Grams', with: first_receipe_ingredient.grams)
    end

    within all('.nested-form-wrapper')[1] do
      second_ingredient = receipe.ingredients.second
      second_receipe_ingredient = receipe.receipe_ingredients.second

      expect(page).to have_field('Name', with: second_ingredient.name)
      expect(page).to have_field('Quantity', with: second_receipe_ingredient.quantity)
      expect(page).to have_field('Grams', with: second_receipe_ingredient.grams)
    end

    fill_in 'receipe_name', with: 'Receipe name'
    fill_in 'Description', with: 'Some description'
    fill_in 'Instruction', with: 'Some instruction'

    within all('.nested-form-wrapper')[0] do
      fill_in 'Name', with: 'Test 1'
      fill_in 'Quantity', with: 1
      fill_in 'Grams', with: 50
    end

    within all('.nested-form-wrapper')[1] do
      fill_in 'Name', with: 'Test 2'
      fill_in 'Quantity', with: 2
      fill_in 'Grams', with: 100
    end

    click_link_or_button('Update Receipe')
    sleep(0.1)

    receipe = Receipe.last
    expect(receipe).to have_attributes(
      name: 'Receipe name',
      description: 'Some description',
      instructions: 'Some instruction',
    )

    expect(receipe.receipe_ingredients.size).to eq(2)

    first_ri = receipe.receipe_ingredients.first
    expect(first_ri).to have_attributes(quantity: 1, grams: 50)

    expect(first_ri.ingredient).to have_attributes(name: 'test 1')

    second_ri = receipe.receipe_ingredients.second
    expect(second_ri).to have_attributes(quantity: 2, grams: 100)

    expect(second_ri.ingredient).to have_attributes(name: 'test 2')
  end
end
