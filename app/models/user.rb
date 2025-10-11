class User < ApplicationRecord
  has_many :my_receipes
  has_many :filters, class_name: "UserFilter"
  has_one :receipe_filter, -> { receipes.order(id: :desc) }, class_name: "UserFilter"
  has_one :my_receipe_filter, -> { my_receipes.order(id: :desc) }, class_name: "UserFilter"

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
end
