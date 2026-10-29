module SavedReceipes
  class IndexController < ApplicationController
    before_action :require_user
    before_action :set_receipe, only: %i[show remove]

    def index
      if params.dig(:filters, :remove_filters) == "true"
        current_user.my_receipe_filter&.destroy
        redirect_to saved_receipes_path and return
      end

      @filter_form = ReceipeFilterForm.new(
        params:,
        receipe_class: MyReceipe,
        user: current_user,
        base_scope: current_user.my_receipes.published
      )
      # Cache this
      @tags = GlobalReceipe.pluck(:tags).flatten.compact_blank.uniq
      @pagy, @receipes = pagy(@filter_form.filtered_receipes)
    end

    def show; end

    def remove
      @my_receipe.destroy!

      redirect_to saved_receipes_path, notice: "Receipe removed from my receipes", status: :see_other
    end

    private

    def set_receipe
      @my_receipe = current_user.my_receipes.find(params.expect(:id))
    end
  end
end
