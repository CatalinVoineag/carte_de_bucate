require "rails_helper"

describe "Editing, deleting and removing receipes", type: :feature, js: true do
  let(:user) { create(:user, email: "cook@example.com") }
  let(:other) { create(:user, email: "alice@example.com") }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def published_receipe(name:, author:)
    receipe = create(:global_receipe, :with_image, name:, author:)
    ReceipeService::User.save(receipe:, user: author)
    receipe
  end

  it "edits a receipe from the Receipes tab" do
    receipe = published_receipe(name: "Old name", author: user)

    visit receipe_path(receipe)
    click_link "Edit receipe"
    fill_in "Name", with: "New name"
    click_button "Continue"

    expect(page).to have_content("Step 2 of 3")
    expect(receipe.reload.name).to eq("New name")
  end

  it "deletes a receipe from the Receipes tab, and it disappears from My receipes" do
    receipe = published_receipe(name: "Going away", author: other)
    visit receipe_path(receipe)

    accept_confirm { click_button "Delete receipe" }

    expect(page).to have_current_path(receipes_path)
    expect(page).not_to have_content("Going away")
    expect(GlobalReceipe.exists?(receipe.id)).to be false
    expect(MyReceipe.where(global_receipe_id: receipe.id)).to be_empty
  end

  it "removes a copy from My receipes without touching the Receipes tab" do
    receipe = published_receipe(name: "Keep me", author: other)
    ReceipeService::User.save(receipe:, user:)
    visit saved_receipe_path(user.my_receipes.find_by(global_receipe_id: receipe.id))

    click_button "Remove from my receipes"

    expect(page).to have_current_path(saved_receipes_path)
    expect(page).not_to have_content("Keep me")
    expect(GlobalReceipe.exists?(receipe.id)).to be true
  end
end
