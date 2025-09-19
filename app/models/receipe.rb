class Receipe < ApplicationRecord
  has_many :ingredients

  accepts_nested_attributes_for :ingredients, reject_if: :all_blank
end
