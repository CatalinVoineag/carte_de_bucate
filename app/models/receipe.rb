# STI for receipe and saved_receipe
class Receipe < ApplicationRecord
  include PgSearch::Model

  IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_IMAGE_SIZE = 5.megabytes

  has_many :receipe_ingredients, dependent: :destroy
  has_many :ingredients, -> { distinct }, through: :receipe_ingredients
  has_many :instructions, -> { order(:step) }, dependent: :destroy
  has_one_attached :image

  # Blank rows are kept so they can show a validation error instead of disappearing
  accepts_nested_attributes_for :receipe_ingredients, allow_destroy: true
  accepts_nested_attributes_for :instructions, allow_destroy: true

  enum :status, {
    draft: "draft",
    published: "published"
  }

  # Only the create-receipe wizard uses these contexts. Saving existing or scraped receipes
  # (including copies made when a user saves one) must keep working, so the rules stay off by default.
  WIZARD_CONTEXTS = %i[draft ingredients publish].freeze

  validates :name, presence: true, length: { maximum: 150 }, on: WIZARD_CONTEXTS
  validates :prep_time, :cook_time, :servings, length: { maximum: 50 }, on: WIZARD_CONTEXTS

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: {
                      prefix: true,
                      normalization: 2,
                      dictionary: "english"
                    }
                  }

  pg_search_scope :search_by_tags, against: :tags

  private
end
