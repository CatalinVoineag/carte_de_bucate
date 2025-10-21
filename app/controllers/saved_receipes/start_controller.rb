module SavedReceipes
  class StartController < ApplicationController
    before_action :my_receipe, only: %i[edit update]
    def new
      @start_form = StartForm.new
    end

    def create
      @start_form = StartForm.new(current_user.my_receipes.new)
      @start_form.assign_attributes(start_form_params)

      if my_receipe = @start_form.save
        redirect_to new_saved_receipe_ingredient_path(my_receipe)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @start_form = StartForm.new(my_receipe)
    end

    def update
      @start_form = StartForm.new(my_receipe)
      @start_form.assign_attributes(start_form_params)

      if @start_form.save
        redirect_to new_saved_receipe_ingredient_path(my_receipe)
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def my_receipe
      @my_receipe ||= MyReceipe.find(params.require(:saved_receipe_id))
    end

    def start_form_params
      params.expect(
        saved_receipes_start_form: [
          :image,
          :name,
          :prep_time,
          :cook_time,
          :servings,
          :description
        ]
      ).merge(
        status: "draft",
      ).compact_blank
    end
  end
end
