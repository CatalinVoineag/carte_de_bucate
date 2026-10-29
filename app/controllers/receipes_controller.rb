class ReceipesController < ApplicationController
  before_action :set_receipe, only: %i[show destroy]
  before_action :require_user, only: %i[destroy]

  # GET /receipes or /receipes.json
  def index
    if params.dig(:filters, :remove_filters) == "true"
      current_user&.receipe_filter&.destroy
      redirect_to receipes_path and return
    end

    @filter_form = ReceipeFilterForm.new(
      params:,
      receipe_class: GlobalReceipe,
      user: current_user,
    )
    # Cache this
    @tags = GlobalReceipe.pluck(:tags).flatten.compact_blank.uniq
    @drafts = current_user ? GlobalReceipe.draft.where(user_id: current_user.id).order(updated_at: :desc) : GlobalReceipe.none
    @pagy, @receipes = pagy(@filter_form.filtered_receipes)
  end

  # GET /receipes/1 or /receipes/1.json
  def show
  end

  # DELETE /receipes/1 or /receipes/1.json
  def destroy
    ReceipeService::DestroyReceipe.call(receipe: @receipe)

    respond_to do |format|
      format.html { redirect_to receipes_path, notice: "Receipe deleted", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_receipe
    @receipe = GlobalReceipe.find(params.expect(:id))
  end
end
