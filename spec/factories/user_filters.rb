FactoryBot.define do
  factory :user_filter do
    user
    kind { "receipes" }
    filters { {} }
    pagination_page { 1 }
  end
end
