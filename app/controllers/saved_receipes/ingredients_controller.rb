module SavedReceipes
  class IngredientsController < ApplicationController
    before_action :my_receipe

    def new
      @receipe_ingredient = ReceipeIngredient.new
      @receipe_ingredient.build_ingredient
      @ingredients_form = IngredientsForm.new(my_receipe)
    end

    def create
      @ingredients_form = IngredientsForm.new(ingredients_form_params)

      if @ingredients_form.save
        redirect_to root_path
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def ingredients_form_params
      params.expect(
        saved_receipes_ingredients_form: [
          :name,
          :prep_time,
          :cook_time,
          :servings,
          :description
        ]
      ).merge(global_receipe:)
    end

    def my_receipe
      @my_receipe ||= MyReceipe.find(params.require(:saved_receipe_id))
    end
  end
end
