require "rails_helper"

RSpec.describe DataMigrations::MoveMyReceipesToReceipes do
  let(:user) { create(:user, email: "cook@example.com") }
  let(:output) { StringIO.new }

  def old_form_receipe(status:, name: "Old receipe")
    receipe = build(:my_receipe, user:, name:, status:)
    receipe.receipe_ingredients = build_list(:receipe_ingredient, 2)
    receipe.instructions = [ build(:instruction, step: 1, body: "One"), build(:instruction, step: 2, body: "Two") ]
    receipe.image.attach(io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")), filename: "a.jpg", content_type: "image/jpeg")
    receipe.save!
    receipe
  end

  it "changes nothing on a dry run, which is the default" do
    old = old_form_receipe(status: "published")

    summary = described_class.new(dry_run: true, output:).call

    expect(summary.published_moved).to eq(1)
    expect(output.string).to include("[dry run] would move")
    expect(old.reload.global_receipe_id).to be_nil
    expect(GlobalReceipe.count).to eq(0)
  end

  it "moves a published receipe to the Receipes tab and links the creator's copy to it" do
    old = old_form_receipe(status: "published", name: "Grandma's soup")

    described_class.new(dry_run: false, output:).call

    global = GlobalReceipe.find_by(name: "Grandma's soup")
    expect(global).to be_present
    expect(global).to be_published
    expect(global.author).to eq(user)
    expect(global.receipe_ingredients.count).to eq(2)
    expect(global.instructions.order(:step).pluck(:body)).to eq(%w[One Two])
    expect(global.image).to be_attached
    expect(old.reload.global_receipe_id).to eq(global.id)
    expect(MyReceipe.exists?(old.id)).to be true
  end

  it "moves a draft to a draft in the Receipes tab and removes the old My receipes draft" do
    old = old_form_receipe(status: "draft", name: "Half done")

    described_class.new(dry_run: false, output:).call

    global = GlobalReceipe.find_by(name: "Half done")
    expect(global).to be_draft
    expect(global.author).to eq(user)
    expect(MyReceipe.exists?(old.id)).to be false
  end

  it "does nothing the second time it runs" do
    old_form_receipe(status: "published")
    old_form_receipe(status: "draft", name: "Half done")
    described_class.new(dry_run: false, output: StringIO.new).call
    counts = [ GlobalReceipe.count, MyReceipe.count, Ingredient.count ]

    summary = described_class.new(dry_run: false, output:).call

    expect([ GlobalReceipe.count, MyReceipe.count, Ingredient.count ]).to eq(counts)
    expect(summary.published_moved + summary.drafts_moved).to eq(0)
  end

  it "leaves saved copies of other people's receipes alone" do
    public_receipe = create(:global_receipe, :with_image)
    copy = MyReceipe.create!(user:, name: "Saved", status: "published", global_receipe: public_receipe)

    described_class.new(dry_run: false, output:).call

    expect(copy.reload.global_receipe_id).to eq(public_receipe.id)
    expect(GlobalReceipe.count).to eq(1)
  end

  it "rolls back a receipe that fails, and carries on with the rest" do
    failing = old_form_receipe(status: "published", name: "Breaks")
    old_form_receipe(status: "published", name: "Works")
    allow(ReceipeService::CopyImage).to receive(:call).and_wrap_original do |original, from:, to:|
      raise "disk full" if from.name == "Breaks"

      original.call(from:, to:)
    end

    summary = described_class.new(dry_run: false, output:).call

    expect(summary.failed).to eq(1)
    expect(summary.published_moved).to eq(1)
    expect(GlobalReceipe.exists?(name: "Breaks")).to be false
    expect(failing.reload.global_receipe_id).to be_nil
    expect(output.string).to include("FAILED")
  end
end
