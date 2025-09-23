require 'rails_helper'

describe "user adds receipe", type: :feature, js: true do
  it "signs me in" do
    visit new_receipe_path

    expect(page).to have_content "New receipe"

    fill_in 'receipe_name', with: 'Receipe name'
    fill_in 'Description', with: 'Description'
    fill_in 'Instruction', with: 'Instruction'

    within all('.nested-form-wrapper')[0] do
      fill_in 'Name', with: 'Ingredient name'
      fill_in 'Quantity', with: 4
      fill_in 'Grams', with: 20
    end

    click_link_or_button('Add ingredient')

    within all('.nested-form-wrapper')[1] do
      fill_in 'Name', with: 'Second ingredient'
      fill_in 'Quantity', with: 1
      fill_in 'Grams', with: 50
    end

    click_link_or_button('Add ingredient')

    within all('.nested-form-wrapper')[2] do
      fill_in 'Name', with: 'Third ingredient'
      fill_in 'Quantity', with: 1
      fill_in 'Grams', with: 50
      click_link_or_button('Remove')
    end

    click_link_or_button('Create Receipe')
    sleep(0.1)

    receipe = Receipe.last
    expect(receipe).to have_attributes(
      name: 'Receipe name',
      description: 'Description',
      instructions: 'Instruction',
    )

    expect(receipe.receipe_ingredients.size).to eq(2)

    first_ri = receipe.receipe_ingredients.first
    expect(first_ri).to have_attributes(quantity: 4, grams: 20)

    expect(first_ri.ingredient).to have_attributes(name: 'ingredient name')

    second_ri = receipe.receipe_ingredients.second
    expect(second_ri).to have_attributes(quantity: 1, grams: 50)

    expect(second_ri.ingredient).to have_attributes(name: 'second ingredient')
  end
end
