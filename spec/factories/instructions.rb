FactoryBot.define do
  factory :instruction do
    step { 1 }
    body { "MyText" }
    receipe { nil }
  end
end
