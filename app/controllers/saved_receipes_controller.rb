class SavedReceipesController < ApplicationController
  before_action :set_receipe, only: %i[ show ]

  def index
    @search_query = params[:query]

    if @search_query.present?
      @receipes = current_user.receipes.search_by_name(@search_query).order(created_at: :desc)
    else
      @receipes = current_user.receipes.all.order(created_at: :desc)
    end

    @receipes.includes(:ingredients)
  end

  def show; end

  private

  def set_receipe
    @receipe = Receipe.find(params.expect(:id))
  end
end
