require "rails_helper"
require Rails.root.join("db/seeds/dev_seeder")

RSpec.describe DevSeeder do
  def counts
    [ User, Ingredient, GlobalReceipe, MyReceipe, ReceipeIngredient, Instruction ].map(&:count)
  end

  it "creates demo data the app can show" do
    expect { DevSeeder.call }.to output.to_stdout

    cook = User.last
    expect(cook.email).to eq("cook@example.com")
    expect(GlobalReceipe.published.count).to be >= 12
    expect(GlobalReceipe.where(user_id: cook.id).published.count).to be >= 1
    expect(GlobalReceipe.where(user_id: cook.id).draft.count).to be >= 1
    expect(cook.my_receipes.count).to be >= 1
    expect(GlobalReceipe.where.not(image_attachment: nil).count).to be >= 12
  end

  it "does not duplicate anything when run again" do
    DevSeeder.call
    before = counts

    expect { DevSeeder.call }.to output.to_stdout
    expect(counts).to eq(before)
  end
end
