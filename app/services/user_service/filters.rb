module UserService
  class Filters
    attr_reader :filters, :user

    def initialize(params:)
      @filters = params.fetch(:filters, {})
      @user = User.last
    end

    def filtered_receipes
      receipes = nil

      if receipe_name.present?
        receipes = GlobalReceipe.search_by_name(receipe_name)
          .order(created_at: :desc)
      end

      if ingredients.present?
        receipes = ReceipeService::SearchByIngredient.call(
          ingredients:,
          scope: receipes.presence || GlobalReceipe
        )
      end

      if receipes.blank?
        receipes = GlobalReceipe.all.order(created_at: :desc)
      else
        UserFilter.upsert(
          { user_id: user.id, filters:, kind: :receipes },
          unique_by: [ :user_id, :kind ]
        )
      end

      receipes
    end

    def receipe_name
      filters[:receipe_name] || user.receipe_filter&.filters&.fetch("receipe_name", nil)
    end

    def ingredients
      filters[:ingredients] || user.receipe_filter&.filters&.fetch("ingredients", nil)
    end
  end
end
