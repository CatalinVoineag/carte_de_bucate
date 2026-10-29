module ReceipeService
  # Saves a published receipe from the Receipes tab to a user's My receipes, or removes that copy again.
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
      return false unless receipe.is_a?(GlobalReceipe) && receipe.published?
      return false if MyReceipe.exists?(user_id: user.id, global_receipe_id: receipe.id)

      dup = receipe.dup

      ActiveRecord::Base.transaction do
        dup.type = "MyReceipe"
        dup.user_id = user.id
        dup.global_receipe_id = receipe.id
        ReceipeService::CopyImage.call(from: receipe, to: dup)
        dup.receipe_ingredients = receipe.receipe_ingredients.map(&:dup)
        dup.instructions = receipe.instructions.map(&:dup)
        dup.save
      end

      dup.persisted?
    end

    def self.remove(receipe:, user:)
      new(receipe:, user:).remove
    end

    # Only removes this user's copy. The public receipe is never touched.
    def remove
      my_copy = user.my_receipes.find_by(global_receipe_id: receipe.id)
      return false if my_copy.nil?

      my_copy.destroy!
      true
    end
  end
end
