module SavedReceipes
  class IndexController < ApplicationController
    before_action :set_receipe, only: %i[ show ]

    def index
      @filter_form = ReceipeFilterForm.new(params:, receipe_class: MyReceipe)
      # Cache this
      @tags = GlobalReceipe.pluck(:tags).flatten.uniq
      @pagy, @receipes = pagy(@filter_form.filtered_receipes)
    end

    def show; end

    private

    def set_receipe
      @my_receipe = current_user.my_receipes.find(params.expect(:id))
    end
  end
end
