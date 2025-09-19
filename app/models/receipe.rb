class Receipe < ApplicationRecord
  include PgSearch::Model

  has_many :ingredients

  accepts_nested_attributes_for :ingredients, reject_if: :all_blank

  pg_search_scope :search_by_name, against: :name
end
