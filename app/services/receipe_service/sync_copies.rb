module ReceipeService
  # Makes every My receipes copy of a receipe match the receipe in the Receipes tab.
  class SyncCopies
    attr_reader :receipe

    def initialize(receipe:)
      @receipe = receipe
    end

    def self.call(receipe:)
      new(receipe:).call
    end

    def call
      receipe.reload
      receipe.saved_copies.find_each { |copy| sync(copy) }
    end

    private

    def sync(copy)
      ActiveRecord::Base.transaction do
        copy.assign_attributes(
          name: receipe.name,
          description: receipe.description,
          prep_time: receipe.prep_time,
          cook_time: receipe.cook_time,
          servings: receipe.servings,
          tags: receipe.tags,
          status: "published"
        )
        copy.save!

        copy.receipe_ingredients.destroy_all
        receipe.receipe_ingredients.each do |receipe_ingredient|
          copy.receipe_ingredients.create!(
            ingredient: receipe_ingredient.ingredient,
            quantity: receipe_ingredient.quantity,
            unit: receipe_ingredient.unit,
            notes: receipe_ingredient.notes
          )
        end

        copy.instructions.destroy_all
        receipe.instructions.each do |instruction|
          copy.instructions.create!(step: instruction.step, body: instruction.body)
        end

        copy_image(copy) if image_changed?(copy)
      end
    end

    def image_changed?(copy)
      receipe.image.attached? && copy.image.blob&.checksum != receipe.image.blob.checksum
    end

    def copy_image(copy)
      ReceipeService::CopyImage.call(from: receipe, to: copy)
    end
  end
end
