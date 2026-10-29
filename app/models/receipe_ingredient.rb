class ReceipeIngredient < ApplicationRecord
  attr_accessor :ingredient_name_input

  belongs_to :receipe
  belongs_to :ingredient, optional: true

  validates :quantity, :unit, length: { maximum: 50 }, on: Receipe::WIZARD_CONTEXTS
  validates :notes, length: { maximum: 255 }, on: Receipe::WIZARD_CONTEXTS

  # there are recipes that don't have quantities

  delegate :name, to: :ingredient, prefix: true, allow_nil: true

  # Never updates an existing Ingredient: it links this row to the ingredient with that name, creating it if needed.
  def ingredient_attributes=(attributes)
    name = attributes.to_h.with_indifferent_access[:name].to_s.strip.downcase
    self.ingredient_name_input = name

    # create_or_find_by! uses a savepoint, so a concurrent insert doesn't abort the surrounding transaction
    self.ingredient = (Ingredient.find_by(name:) || Ingredient.create_or_find_by!(name:) if name.present?)
  end
end
