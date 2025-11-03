module SavedReceipes
  class IngredientsForm
    include ActiveModel::Model

    attr_accessor :my_receipe, :receipe_ingredients_attributes,
                  :receipe_ingredients, :ingredient, :ingredient_attributes


    def initialize(my_receipe)
      @my_receipe = my_receipe
      @receipe_ingredients = my_receipe.receipe_ingredients.presence || [ my_receipe.receipe_ingredients.build ]
      @ingredient = @receipe_ingredients.map(&:build_ingredient)
    end

    def new_record?
      my_receipe.new_record?
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        my_receipe.receipe_ingredients = []
        my_receipe.receipe_ingredients_attributes = receipe_ingredients_attributes
        my_receipe.save!
      end
    end
  end
end
