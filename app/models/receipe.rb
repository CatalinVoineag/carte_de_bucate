# STI for receipe and saved_receipe
class Receipe < ApplicationRecord
  include PgSearch::Model

  has_many :receipe_ingredients, dependent: :destroy
  has_many :ingredients, -> { distinct }, through: :receipe_ingredients
  has_many :instructions, -> { order(:step) }, dependent: :destroy
  has_one_attached :image

  accepts_nested_attributes_for :receipe_ingredients, allow_destroy: true
  accepts_nested_attributes_for :instructions, allow_destroy: true

  enum :status, {
    draft: "draft",
    published: "published"
  }

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: {
                      prefix: true,
                      normalization: 2,
                      dictionary: "english"
                    }
                  }

  pg_search_scope :search_by_tags, against: :tags

  def receipe_ingredients_attributes=(attrs)
    attrs.each do |_, value|
      ingredient = Ingredient.find_by(name: value.dig("ingredient_attributes", "name"))

      if ingredient.present?
        value["ingredient_id"] = ingredient.id
        value.delete("ingredient_attributes")
      end
    end

    super
  end
end
