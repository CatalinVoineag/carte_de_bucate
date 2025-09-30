class ReceipeIngredient < ApplicationRecord
  attr_accessor :ingredient_name

  belongs_to :receipe
  belongs_to :ingredient

  accepts_nested_attributes_for :ingredient, reject_if: :all_blank, allow_destroy: true

  delegate :name, to: :ingredient, prefix: true
end
