class Ingredient < ApplicationRecord
  has_many :receipe_ingredients, dependent: :destroy
  has_many :receipes, through: :receipe_ingredients
  has_one_attached :image

  validates :name, presence: true

  normalizes :name, with: ->(value) { value.strip.downcase }
end
