class SavedReceipesController < ApplicationController
  before_action :set_receipe, only: %i[ show ]

  def index
    @search_query = params[:query]

    if @search_query.present?
      @my_receipes = current_user.my_receipes.search_by_name(@search_query).order(created_at: :desc)
    else
      @my_receipes = current_user.my_receipes.all.order(created_at: :desc)
    end

    @my_receipes.includes(:ingredients)
  end

  def show; end

  private

  def set_receipe
    @my_receipe = current_user.my_receipes.find(params.expect(:id))
  end
end
