# STI for receipe and saved_receipe
class Receipe < ApplicationRecord
  include PgSearch::Model

  has_many :receipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :receipe_ingredients
  has_many :instructions, -> { order(:step) }, dependent: :destroy
  has_one_attached :image

  accepts_nested_attributes_for :receipe_ingredients, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :instructions, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
  validates :type, presence: true
  validates :description, presence: true
  validates :instructions, presence: true
  validates :receipe_ingredients, presence: true

  pg_search_scope :search_by_name, against: :name

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
