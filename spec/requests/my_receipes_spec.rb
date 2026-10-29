require "rails_helper"

RSpec.describe "My receipes", type: :request do
  let(:user) { create(:user, email: "cook@example.com") }
  let(:other) { create(:user, email: "alice@example.com") }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def saved_copy_of(receipe, owner: user)
    MyReceipe.create!(user: owner, name: receipe.name, status: "published", global_receipe: receipe)
  end

  it "lists only the current user's copies" do
    mine = create(:global_receipe, name: "Mine to keep")
    theirs = create(:global_receipe, name: "Alice only")
    saved_copy_of(mine)
    saved_copy_of(theirs, owner: other)

    get saved_receipes_path
    expect(response.body).to include("Mine to keep")
    expect(response.body).not_to include("Alice only")
  end

  it "does not show create, edit, delete or drafts here" do
    create(:global_receipe, :draft, author: user, name: "Half finished")
    saved_copy_of(create(:global_receipe, name: "Saved one"))

    get saved_receipes_path
    expect(response.body).not_to include("Create new receipe")
    expect(response.body).not_to include("Half finished")
    expect(response.body).not_to include("Drafts")
  end

  it "offers only Remove on a copy, with no links back to the Receipes tab" do
    global = create(:global_receipe, name: "Saved one")
    copy = saved_copy_of(global)

    get saved_receipe_path(copy)
    expect(response.body).to include("Remove from my receipes")
    expect(response.body).not_to include(receipe_path(global))
    expect(response.body).not_to include("View in Receipes")
    expect(response.body).not_to include("Back to my receipes")
    expect(response.body).not_to include("Edit receipe")
    expect(response.body).not_to include("Delete receipe")
  end

  it "removes only the user's copy, and keeps the receipe in the Receipes tab" do
    global = create(:global_receipe)
    copy = saved_copy_of(global)
    other_copy = saved_copy_of(global, owner: other)

    delete remove_saved_receipe_path(copy)

    expect(response).to redirect_to(saved_receipes_path)
    expect(MyReceipe.exists?(copy.id)).to be false
    expect(GlobalReceipe.exists?(global.id)).to be true
    expect(other_copy.reload.global_receipe_id).to eq(global.id)
  end

  it "removes the user's own published receipe from My receipes but keeps it in the Receipes tab" do
    global = create(:global_receipe, author: user)
    copy = saved_copy_of(global)

    delete remove_saved_receipe_path(copy)

    expect(GlobalReceipe.exists?(global.id)).to be true
  end

  it "does not let users open or remove another user's copy" do
    copy = saved_copy_of(create(:global_receipe), owner: other)

    get saved_receipe_path(copy)
    expect(response).to have_http_status(:not_found)

    delete remove_saved_receipe_path(copy)
    expect(response).to have_http_status(:not_found)
    expect(MyReceipe.exists?(copy.id)).to be true
  end
end

RSpec.describe "Save and remove on the Receipes tab", type: :request do
  let(:user) { create(:user, email: "cook@example.com") }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  it "offers Save for a published receipe that is not in My receipes" do
    global = create(:global_receipe)

    get receipe_path(global)
    expect(response.body).to include("Save to my receipes")
  end

  it "offers Remove once the receipe is saved, including the user's own" do
    global = create(:global_receipe, author: user)
    MyReceipe.create!(user:, name: global.name, status: "published", global_receipe: global)

    get receipe_path(global)
    expect(response.body).to include("Remove from my receipes")
    expect(response.body).not_to include("Save to my receipes")
  end

  it "saves and removes a copy" do
    global = create(:global_receipe)

    expect { post save_receipes_path(receipe_id: global.id), headers: { "Accept" => "text/html" } }.to change(MyReceipe, :count).by(1)
    expect { delete save_receipe_path(global.id), headers: { "Accept" => "text/html" } }.to change(MyReceipe, :count).by(-1)
    expect(GlobalReceipe.exists?(global.id)).to be true
  end

  it "does not save a draft" do
    draft = create(:global_receipe, :draft, author: user)

    post save_receipes_path(receipe_id: draft.id)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(MyReceipe.count).to eq(0)
  end

  it "does not offer Save or Remove on a draft" do
    draft = create(:global_receipe, :draft, author: user)

    get receipe_path(draft)
    expect(response.body).not_to include("Save to my receipes")
    expect(response.body).not_to include("Remove from my receipes")
  end

  it "underlines the tab for the section on show pages" do
    global = create(:global_receipe)
    copy = MyReceipe.create!(user:, name: global.name, status: "published", global_receipe: global)

    get saved_receipe_path(copy)
    expect(response.body).to include('aria-current="page" href="/saved_receipes"')

    get receipe_path(global)
    expect(response.body).to include('aria-current="page" href="/receipes"')
  end
end
