class ReceipeFilterForm
  attr_reader :filters, :receipe_class, :user

  def initialize(params:, receipe_class:)
    @filters = params.fetch(:filters, {})
    @receipe_class = receipe_class
    @user = User.last
  end

  def filtered_receipes
    receipes = nil

    if receipe_name.present?
      receipes = receipe_class.search_by_name(receipe_name)
        .order(created_at: :desc)
    end

    if ingredients.present?
      receipes = ReceipeService::SearchByIngredient.call(
        ingredients:,
        scope: receipes.presence || receipe_class,
        receipe_class:,
      )
    end

    if receipe_name.blank? && ingredients.blank?
      receipes = receipe_class.all.order(created_at: :desc)
    end

    UserFilter.upsert(
      {
        user_id: user.id,
        filters: sanitised_filters,
        kind: sti_methods[receipe_class.name][:kind]
      },
      unique_by: [ :user_id, :kind ]
    )

    receipes
  end

  def receipe_name
    filters[:receipe_name] ||
      user.public_send(sti_methods[receipe_class.name][:filter])&.filters&.fetch("receipe_name", nil)
  end

  def ingredients
    filters[:ingredients] ||
      user.public_send(sti_methods[receipe_class.name][:filter])&.filters&.fetch("ingredients", nil)
  end

  def sanitised_filters
    if filters[:remove_filters] == true
      {}
    else
      { receipe_name: receipe_name, ingredients: ingredients }
    end
  end

  def sti_methods
    {
      GlobalReceipe: { filter: "receipe_filter", kind: :receipes },
      MyReceipe: { filter: "my_receipe_filter", kind: :my_receipes }
    }.with_indifferent_access
  end
end
