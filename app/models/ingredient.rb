class Ingredient < ApplicationRecord
  include PgSearch::Model

  has_many :receipe_ingredients, dependent: :destroy
  has_many :receipes, class_name: "GlobalReceipe", through: :receipe_ingredients
  has_many :my_receipes,
         -> { where(receipes: { type: "MyReceipe" }) },
         through: :receipe_ingredients,
         source: :receipe

  has_one_attached :image

  validates :name, presence: true

  normalizes :name, with: ->(value) { value.strip.downcase }

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: {
                      prefix: true,
                      normalization: 2,
                      dictionary: "english"
                    }
                  }
end
