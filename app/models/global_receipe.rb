# A receipe in the Receipes tab. Scraped ones have no author; receipes created in the app are authored by their creator.
class GlobalReceipe < Receipe
  belongs_to :author, class_name: "User", foreign_key: :user_id, optional: true
  has_many :saved_copies, class_name: "MyReceipe", foreign_key: :global_receipe_id, dependent: :destroy, inverse_of: :global_receipe

  validates :description, :prep_time, :cook_time, :servings, presence: true, on: :publish
  validate :must_have_ingredients, on: :publish
  validate :must_have_instructions, on: :publish
  validate :must_have_image, on: :publish
  validate :ingredient_names_given, on: %i[ingredients publish]
  validate :ingredients_unique, on: %i[ingredients publish]

  private

  def active_receipe_ingredients
    receipe_ingredients.reject(&:marked_for_destruction?)
  end

  def active_instructions
    instructions.reject(&:marked_for_destruction?)
  end

  def must_have_ingredients
    errors.add(:base, "Add at least one ingredient") if active_receipe_ingredients.empty?
  end

  def must_have_instructions
    errors.add(:base, "Add at least one instruction") if active_instructions.empty?
  end

  def must_have_image
    errors.add(:image, "Select an image") unless image.attached?
  end

  def ingredient_names_given
    if active_receipe_ingredients.any? { |ri| ri.ingredient.nil? && ri.ingredient_name_input.blank? }
      errors.add(:base, "Enter a name for every ingredient")
    end

    if active_receipe_ingredients.any? { |ri| ri.ingredient_name_input.to_s.length > Ingredient::NAME_MAX }
      errors.add(:base, "Ingredient names must be #{Ingredient::NAME_MAX} characters or fewer")
    end
  end

  def ingredients_unique
    names = active_receipe_ingredients.filter_map { |ri| ri.ingredient&.name }

    names.tally.each do |name, count|
      errors.add(:base, "#{name.capitalize} is listed more than once") if count > 1
    end
  end
end
