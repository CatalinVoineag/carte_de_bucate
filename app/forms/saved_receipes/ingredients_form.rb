module SavedReceipes
  class IngredientsForm
    include ActiveModel::Model

    attr_accessor :my_receipe


    def initialize(my_receipe)
      @my_receipe = my_receipe
    end

    def save
      return false unless valid?

      byebug
      global_receipe
    end
  end
end
