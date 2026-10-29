class SaveReceipesController < ApplicationController
  before_action :require_user

  def create
    receipe = GlobalReceipe.find_by(id: params.require(:receipe_id))

    if receipe.present? && ReceipeService::User.save(receipe:, user: current_user)
      respond_to do |format|
        format.html { redirect_to receipe_path(receipe) }
        format.turbo_stream { render locals: { receipe: } }
      end
    else
      head :unprocessable_entity
    end
  end

  def destroy
    receipe = GlobalReceipe.find_by(id: params.require(:id))

    if receipe.present? && ReceipeService::User.remove(receipe:, user: current_user)
      respond_to do |format|
        format.html { redirect_to receipe_path(receipe) }
        format.turbo_stream { render locals: { receipe: } }
      end
    else
      head :unprocessable_entity
    end
  end
end
