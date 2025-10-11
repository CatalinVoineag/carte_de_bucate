module ReceipeService
  class SearchByIngredient
    attr_reader :ingredients_array, :scope, :receipe_class

    def initialize(ingredients:, scope:, receipe_class:)
      @ingredients_array = ingredients.split(",")
      @scope = scope
      @receipe_class = receipe_class
    end

    def self.call(ingredients:, scope:, receipe_class:)
      new(ingredients:, scope:, receipe_class:).call
    end

    def call
      receipes = {}

      ingredients_array.each do |ingredient_name|
        ingredient = Ingredient.search_by_name(ingredient_name).first
        next if ingredient.blank?

        ingredient.public_send(receipe_method).each do |receipe_id|
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

  private

    def receipe_method
      if receipe_class.name == "MyReceipe"
        "my_receipe_ids"
      elsif receipe_class.name == "GlobalReceipe"
        "receipe_ids"
      end
    end
  end
end
