module SavedReceipes
  class InstructionsController < ApplicationController
    before_action :my_receipe

    def new
      my_receipe.instructions.build if my_receipe.instructions.blank?
    end

    def create
      if my_receipe.update(instructions_form_params)
        my_receipe.published!
        redirect_to saved_receipes_path
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def instructions_form_params
      params.expect(
        my_receipe: [
          instructions_attributes: [ [
            :step,
            :body,
            :_destroy
          ] ]
        ]
      )
    end

    def my_receipe
      @my_receipe ||= MyReceipe.find(params.require(:saved_receipe_id))
    end
  end
end
