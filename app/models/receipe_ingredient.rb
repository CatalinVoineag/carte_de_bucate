class ReceipeIngredient < ApplicationRecord
  attr_accessor :ingredient_name

  belongs_to :receipe
  belongs_to :ingredient, optional: true

  accepts_nested_attributes_for :ingredient, reject_if: :all_blank, allow_destroy: true

#  validates :ingredient_name, presence: true
end
