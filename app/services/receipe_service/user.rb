module ReceipeService
  class User
    attr_reader :receipe, :user

    def initialize(receipe:, user:)
      @receipe = receipe
      @user = user
    end

    def self.save(receipe:, user:)
      new(receipe:, user:).save
    end

    def save
      # This needs to create a new receipe, dup with all associations
      return false if receipe.user.present?

      receipe.update(user:)
    end

    def self.remove(receipe:, user:)
      new(receipe:, user:).remove
    end

    def remove
      # Remove saved receipe STI record
      Receipe.find_by(user_id: user.id)&.update(user_id: nil)
    end
  end
end
