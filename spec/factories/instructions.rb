FactoryBot.define do
  factory :instruction do
    sequence(:step) { |n| n }
    sequence(:body) { |n| "Step body #{n}" }
  end
end
