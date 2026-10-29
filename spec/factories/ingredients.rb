FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "ingredient #{n}" }
  end

  factory :receipe_ingredient do
    ingredient
    quantity { "1" }
    unit { "cup" }
    notes { nil }
  end
end
