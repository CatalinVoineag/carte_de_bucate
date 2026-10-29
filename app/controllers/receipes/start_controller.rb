module Receipes
  class StartController < ApplicationController
    before_action :require_user

    def new
      @start_form = StartForm.new
    end

    def create
      @start_form = StartForm.new(GlobalReceipe.new(status: "draft", author: current_user))
      @start_form.assign_attributes(start_form_params)

      if (receipe = @start_form.save)
        redirect_to new_receipe_ingredient_path(receipe)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @start_form = StartForm.new(receipe)
    end

    def update
      @start_form = StartForm.new(receipe)
      @start_form.assign_attributes(start_form_params)

      if @start_form.save
        redirect_to new_receipe_ingredient_path(receipe)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def receipe
      @receipe ||= GlobalReceipe.find(params.expect(:id))
    end

    def start_form_params
      params.expect(
        receipes_start_form: [
          :image,
          :name,
          :prep_time,
          :cook_time,
          :servings,
          :description,
          :tags
        ]
      )
    end
  end
end
