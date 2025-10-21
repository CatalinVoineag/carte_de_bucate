module SavedReceipes
  class StartForm
    include ActiveModel::Model

    attr_accessor :my_receipe, :name, :status, :prep_time, :cook_time,
                       :servings, :description, :image

    validates :image, presence: true
    validates :name, presence: true
    validates :prep_time, presence: true
    validates :cook_time, presence: true
    validates :servings, presence: true
    validates :description, presence: true

    def initialize(my_receipe = nil)
      @my_receipe = my_receipe
      @name = my_receipe&.name
      @prep_time = my_receipe&.prep_time
      @cook_time = my_receipe&.cook_time
      @servings = my_receipe&.servings
      @description = my_receipe&.description
      @status = my_receipe&.status
    end

    def save
      return false unless valid?

      my_receipe.assign_attributes(
        { image:, name:, prep_time:, cook_time:, servings:, description:, status: }
      )
      my_receipe.save!
      my_receipe
    end
  end
end
