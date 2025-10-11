module ReceipeService
  class SearchByIngredient
    attr_reader :ingredients_array, :scope

    def initialize(ingredients:, scope:)
      @ingredients_array = ingredients.split(",")
      @scope = scope
    end

    def self.call(ingredients:, scope:)
      new(ingredients:, scope:).call
    end

    def call
      receipes = {}

      ingredients_array.each do |ingredient_name|
        ingredient = Ingredient.search_by_name(ingredient_name).first
        next if ingredient.blank?

        ingredient.receipe_ids.each do |receipe_id|
          if receipes[receipe_id].present?
            # receipes with most ingredient matches will have most negative number
            receipes[receipe_id] = receipes[receipe_id] - 1
          else
            receipes[receipe_id] = 1
          end
        end
      end

      receipe_ids = receipes.sort_by { |key, value| value }.map { |e| e.first }
      scope.where(id: receipe_ids).sort_by { |receipe| receipe_ids.index(receipe.id) }
    end
  end
end
