class ReceipeIngredient < ApplicationRecord
  attr_accessor :ingredient_name

  belongs_to :receipe
  belongs_to :ingredient

  accepts_nested_attributes_for :ingredient, allow_destroy: true

  # validates :quantity, presence: true
  # there are recipes that don't have quantities

  delegate :name, to: :ingredient, prefix: true
end
