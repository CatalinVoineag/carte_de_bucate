FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "Ingredient #{n}" }
  end
end

FactoryBot.define do
  factory :receipe_ingredient do
    ingredient  # builds an ingredient by default
    quantity { 1 }
    grams    { 20 }
  end
end

FactoryBot.define do
  factory :receipe do
    name { 'Receipe name' }
    description { 'Description' }
    instructions { 'Instruction' }

    after(:build) do |receipe|
      receipe.receipe_ingredients << build(:receipe_ingredient, receipe: receipe) if receipe.receipe_ingredients.blank?
    end

    trait :with_ingredients do
      transient do
        ingredients_count { 2 }
      end

      after(:build) do |receipe, evaluator|
        receipe.receipe_ingredients = build_list(:receipe_ingredient, evaluator.ingredients_count, receipe: receipe)
      end
    end
  end
end
