# frozen_string_literal: true

class IngredientComponent < ViewComponent::Base
  attr_reader :receipe_ingredient

  def initialize(receipe_ingredient:)
    @receipe_ingredient = receipe_ingredient
  end

  def render?
    receipe_ingredient.present?
  end

  def format
    if receipe_ingredient.notes.present?
      notes = receipe_ingredient.notes
      notes.gsub!("${}", receipe_ingredient.ingredient_name)

      "#{receipe_ingredient.quantity}#{receipe_ingredient&.unit} \
        #{notes}"
    else
      "#{receipe_ingredient.quantity}#{receipe_ingredient&.unit} \
        #{receipe_ingredient.ingredient&.name}"
    end
  end
end
