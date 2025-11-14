module SavedReceipes
  class IngredientsController < ApplicationController
    before_action :my_receipe

    def new
      if my_receipe.receipe_ingredients.blank?
        my_receipe.receipe_ingredients.build
        my_receipe.receipe_ingredients.map(&:build_ingredient)
      end
    end

    def create
      if my_receipe.update(ingredients_form_params)
        redirect_to new_saved_receipe_instruction_path(my_receipe)
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def ingredients_form_params
      params.expect(
        my_receipe: [
          receipe_ingredients_attributes: [ [
            :id,
            :quantity,
            :unit,
            :notes,
            :_destroy,
            ingredient_attributes: [ :id, :name ]
          ]
        ] ]
      )
    end

    def my_receipe
      @my_receipe ||= MyReceipe.find(params.require(:saved_receipe_id))
    end
  end
end
