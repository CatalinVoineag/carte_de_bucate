module SavedReceipes
  class InstructionForm
    include ActiveModel::Model

    attr_accessor :my_receipe, :instructions, :instructions_attributes

    def initialize(my_receipe)
      @my_receipe = my_receipe
      @instructions = my_receipe.instructions.presence || [ my_receipe.instructions.build ]
    end

    def new_record?
      my_receipe.new_record?
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        my_receipe.instructions = []
        my_receipe.instructions_attributes = instructions_attributes
        my_receipe.status = :published
        my_receipe.save!
      end
    end
  end
end
