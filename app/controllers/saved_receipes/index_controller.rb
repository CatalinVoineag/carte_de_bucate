module SavedReceipes
  class IndexController < ApplicationController
    before_action :set_receipe, only: %i[ show ]

    def index
      if params.dig(:filters, :remove_filters) == "true"
        current_user.my_receipe_filter&.destroy
        redirect_to saved_receipes_path and return
      end

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
