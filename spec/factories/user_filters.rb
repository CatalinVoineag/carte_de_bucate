FactoryBot.define do
  factory :user_filter do
    user { nil }
    kind { "MyString" }
    filters { "" }
    pagination_page { 1 }
  end
end
