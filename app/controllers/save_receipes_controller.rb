class SaveReceipesController < ApplicationController
  def create
    receipe = Receipe.find_by(id: params.require(:receipe_id))

    if receipe.present? && ReceipeService::User.save(receipe:, user: current_user)
      respond_to do |format|
        format.html { redirect_to recipe_path(receipe) }
        format.turbo_stream { render locals: { receipe: } }
      end
    else
      render json: {}, status: :bad_request
    end
  end

  def destroy
    receipe = Receipe.find_by(id: params.require(:id))

    if receipe.present? && ReceipeService::User.remove(receipe:, user: current_user)
      respond_to do |format|
        format.html { redirect_to recipe_path(receipe) }
        format.turbo_stream { render locals: { receipe: } }
      end
    else
      render json: {}, status: :bad_request
    end
  end
end
