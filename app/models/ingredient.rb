class Ingredient < ApplicationRecord
  has_many :receipe_ingredients, dependent: :destroy
  has_many :receipes, through: :receipe_ingredients

  validates :name, presence: true
end
