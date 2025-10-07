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
      dup = receipe.dup

      ActiveRecord::Base.transaction do
        dup.type = "MyReceipe"
        dup.user_id = user.id
        dup.global_receipe_id = receipe.id
        dup.image.attach(receipe.image.blob)
        dup.ingredients = receipe.ingredients
        dup.instructions = receipe.instructions.map(&:dup)
        dup.save
      end

      dup.persisted?
    end

    def self.remove(receipe:, user:)
      new(receipe:, user:).remove
    end

    def remove
      user.my_receipes.find_by(global_receipe_id: receipe.id)&.destroy
    end
  end
end
