module ReceipeService
  # Deletes a receipe from the database. Its copies in everyone's My receipes are deleted too (see GlobalReceipe#saved_copies).
  class DestroyReceipe
    attr_reader :receipe

    def initialize(receipe:)
      @receipe = receipe
    end

    def self.call(receipe:)
      new(receipe:).call
    end

    def call
      receipe.destroy!
    end
  end
end
