class UserFilter < ApplicationRecord
  belongs_to :user

  enum :kind, {
    receipes: "receipes",
    my_receipes: "my_receipes"
  }
end
