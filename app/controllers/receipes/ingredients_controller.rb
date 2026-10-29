module Receipes
  class IngredientsController < ApplicationController
    before_action :require_user
    before_action :receipe

    def new
      receipe.receipe_ingredients.build if receipe.receipe_ingredients.blank?
    end

    def create
      saved = false

      ActiveRecord::Base.transaction do
        receipe.assign_attributes(ingredients_form_params)

        if receipe.receipe_ingredients.none? { |ri| !ri.marked_for_destruction? }
          receipe.errors.add(:base, "Add at least one ingredient")
          raise ActiveRecord::Rollback
        end

        saved = receipe.save(context: receipe.published? ? :publish : :ingredients)
        raise ActiveRecord::Rollback unless saved
      end

      if saved
        ReceipeService::SyncCopies.call(receipe:) if receipe.published?
        redirect_to new_receipe_instruction_path(receipe)
      else
        # Keep one row on the page so the form is still there to correct
        receipe.receipe_ingredients.build if receipe.receipe_ingredients.empty?
        render :new, status: :unprocessable_entity
      end
    end

    private

    def ingredients_form_params
      params.expect(
        global_receipe: [
          receipe_ingredients_attributes: [ [
            :id,
            :quantity,
            :unit,
            :notes,
            :_destroy,
            ingredient_attributes: [ :name ]
          ] ]
        ]
      )
    end

    def receipe
      @receipe ||= GlobalReceipe.find(params.require(:receipe_id))
    end
  end
end
