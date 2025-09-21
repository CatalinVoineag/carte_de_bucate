class Receipe < ApplicationRecord
  include PgSearch::Model

  has_many :receipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :receipe_ingredients

  accepts_nested_attributes_for :ingredients, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :receipe_ingredients, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
  validates :description, presence: true
  validates :instructions, presence: true

  pg_search_scope :search_by_name, against: :name
end
