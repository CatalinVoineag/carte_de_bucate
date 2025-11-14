class Instruction < ApplicationRecord
  belongs_to :receipe

  validates :body, presence: true
end
