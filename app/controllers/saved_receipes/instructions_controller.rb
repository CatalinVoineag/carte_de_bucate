module SavedReceipes
  class InstructionsController < ApplicationController
    before_action :my_receipe

    def new
      @instructions_form = InstructionForm.new(my_receipe)
    end

    def create
      @instructions_form = InstructionForm.new(my_receipe)
      @instructions_form.assign_attributes(instructions_form_params)

      if @instructions_form.save
        redirect_to root_path
      else
        render :new, status: :unprocessable_entity
      end
    end

  private

    def instructions_form_params
      params.expect(
        saved_receipes_instruction_form: [
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
