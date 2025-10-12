class ReceipeFilterForm
  include ActiveModel::Model

  attr_reader :filters, :receipe_class, :user
  attr_accessor :receipe_name, :ingredients, :tags

  def initialize(params:, receipe_class:)
    @filters = params.fetch(:filters, {})
    @receipe_class = receipe_class
    @user = User.last

    @receipe_name = @filters[:receipe_name] ||
      @user.public_send(sti_methods[receipe_class.name][:filter])&.filters&.fetch("receipe_name", nil)
    @ingredients = @filters[:ingredients] ||
      @user.public_send(sti_methods[receipe_class.name][:filter])&.filters&.fetch("ingredients", nil)
    @tags = @filters[:tags]&.compact_blank ||
      @user.public_send(sti_methods[receipe_class.name][:filter])&.filters&.fetch("tags", {})
  end

  def filtered_receipes
    receipes = receipe_class.published.all

    if receipe_name.present?
      receipes = receipes.search_by_name(receipe_name)
    end

    if tags.present?
      receipes = receipes.search_by_tags(tags)
    end

    if ingredients.present?
      receipes = ReceipeService::SearchByIngredient.call(
        ingredients:,
        receipe_scope: receipes,
        receipe_class:,
      )
    end

    UserFilter.upsert(
      {
        user_id: user.id,
        filters: sanitised_filters,
        kind: sti_methods[receipe_class.name][:kind]
      },
      unique_by: [ :user_id, :kind ]
    )

    receipes.order(created_at: :desc)
  end

  private

  def sanitised_filters
    if filters[:remove_filters] == true
      {}
    else
      { receipe_name:, ingredients:, tags: }
    end
  end

  def sti_methods
    {
      GlobalReceipe: { filter: "receipe_filter", kind: :receipes },
      MyReceipe: { filter: "my_receipe_filter", kind: :my_receipes }
    }.with_indifferent_access
  end
end
