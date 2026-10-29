module Receipes
  class InstructionsController < ApplicationController
    before_action :require_user
    before_action :receipe

    def new
      receipe.instructions.build if receipe.instructions.blank?
    end

    def create
      first_publish = receipe.draft?
      receipe.assign_attributes(instructions_form_params)
      receipe.status = "published"

      if receipe.save(context: :publish)
        # Publishing adds it to the publisher's My receipes; later edits by anyone only sync existing copies
        ReceipeService::User.save(receipe:, user: current_user) if first_publish
        ReceipeService::SyncCopies.call(receipe:)

        redirect_to receipe_path(receipe), notice: "Receipe published"
      else
        receipe.instructions.build if receipe.instructions.empty?
        render :new, status: :unprocessable_entity
      end
    end

    private

    def instructions_form_params
      params.expect(
        global_receipe: [
          instructions_attributes: [ [
            :id,
            :step,
            :body,
            :_destroy
          ] ]
        ]
      )
    end

    def receipe
      @receipe ||= GlobalReceipe.find(params.require(:receipe_id))
    end
  end
end
