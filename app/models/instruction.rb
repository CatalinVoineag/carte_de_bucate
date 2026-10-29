class Instruction < ApplicationRecord
  belongs_to :receipe

  validates :step, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :body, presence: { message: "Enter the instruction" }
end
