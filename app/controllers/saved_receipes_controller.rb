class SavedReceipesController < ApplicationController
  before_action :set_receipe, only: %i[ show ]

  def index
    filter_form = ReceipeFilterForm.new(params:, receipe_class: MyReceipe)
    @my_receipes = filter_form.filtered_receipes
    @receipe_name_query = filter_form.receipe_name.presence
    @ingredients_query = filter_form.ingredients.presence
  end

  def show; end

  private

  def set_receipe
    @my_receipe = current_user.my_receipes.find(params.expect(:id))
  end
end
