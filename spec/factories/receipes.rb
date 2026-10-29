IMAGE_PATH = Rails.root.join("spec/fixtures/files/test_image.jpg")

FactoryBot.define do
  factory :global_receipe, class: "GlobalReceipe" do
    sequence(:name) { |n| "Global receipe #{n}" }
    description { "A tasty receipe" }
    prep_time { "10 mins" }
    cook_time { "20 mins" }
    servings { "Serves 4" }
    tags { [] }
    status { "published" }

    transient do
      ingredients_count { 2 }
      instructions_count { 2 }
    end

    after(:build) do |receipe, evaluator|
      receipe.receipe_ingredients = build_list(:receipe_ingredient, evaluator.ingredients_count) if receipe.receipe_ingredients.empty?
      receipe.instructions = (1..evaluator.instructions_count).map { |step| build(:instruction, step:) } if receipe.instructions.empty?
    end

    trait :draft do
      status { "draft" }
    end

    trait :with_image do
      after(:build) do |receipe|
        receipe.image.attach(io: File.open(IMAGE_PATH), filename: "test_image.jpg", content_type: "image/jpeg")
      end
    end

    trait :authored do
      association :author, factory: :user
    end
  end

  factory :my_receipe, class: "MyReceipe" do
    sequence(:name) { |n| "My receipe #{n}" }
    description { "My own receipe" }
    prep_time { "5 mins" }
    cook_time { "15 mins" }
    servings { "Serves 2" }
    tags { [] }
    status { "published" }
    association :user

    trait :with_image do
      after(:build) do |receipe|
        receipe.image.attach(io: File.open(IMAGE_PATH), filename: "test_image.jpg", content_type: "image/jpeg")
      end
    end
  end
end
