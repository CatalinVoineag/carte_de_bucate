module SavedReceipes
  class IngredientsController < ApplicationController
    before_action :my_receipe

    def new
      @receipe_ingredient = ReceipeIngredient.new
      @receipe_ingredient.build_ingredient
      @ingredients_form = IngredientsForm.new(my_receipe)
    end

    def create
      @ingredients_form = IngredientsForm.new(my_receipe)
      @ingredients_form.assign_attributes(ingredients_form_params)

      if @ingredients_form.save
        redirect_to new_saved_receipe_instruction_path(my_receipe)
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def ingredients_form_params
      params.expect(
        saved_receipes_ingredients_form: [
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
