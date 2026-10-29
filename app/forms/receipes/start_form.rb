module Receipes
  class StartForm
    include ActiveModel::Model

    attr_accessor :receipe, :name, :prep_time, :cook_time, :servings, :description, :tags, :image

    validates :name, presence: { message: "Enter a name for the receipe" }
    validates :prep_time, presence: { message: "Enter the prep time" }
    validates :cook_time, presence: { message: "Enter the cook time" }
    validates :servings, presence: { message: "Enter the number of servings" }
    validates :description, presence: { message: "Enter a description" }
    validates :name, length: { maximum: 150 }
    validates :prep_time, :cook_time, :servings, length: { maximum: 50 }
    validate :image_selected
    validate :image_is_valid

    def initialize(receipe = nil)
      @receipe = receipe
      @name = receipe&.name
      @prep_time = receipe&.prep_time
      @cook_time = receipe&.cook_time
      @servings = receipe&.servings
      @description = receipe&.description
      @tags = receipe&.tags&.join(", ")
    end

    def save
      return false unless valid?

      receipe.assign_attributes(
        name:, prep_time:, cook_time:, servings:, description:, tags: parsed_tags
      )
      receipe.image = image if uploaded_image?

      # Copies are synced after the save so a new upload is on disk before its bytes are copied
      # Step 1 only checks the details. Ingredient and instruction rules run on their own steps.
      if receipe.save(context: :draft)
        ReceipeService::SyncCopies.call(receipe:) if receipe.published?
        receipe
      else
        receipe.errors.each { |error| errors.add(error.attribute, error.message) }
        false
      end
    end

    private

    def uploaded_image?
      image.respond_to?(:content_type)
    end

    def parsed_tags
      tags.to_s.split(",").map(&:strip).compact_blank.uniq
    end

    def image_selected
      return if uploaded_image? || receipe&.image&.attached?

      errors.add(:image, "Select an image")
    end

    def image_is_valid
      return unless uploaded_image?

      unless Receipe::IMAGE_TYPES.include?(image.content_type)
        errors.add(:image, "Image must be a JPG, PNG, WEBP or GIF")
      end
      errors.add(:image, "Image must be smaller than 5MB") if image.size > Receipe::MAX_IMAGE_SIZE
    end
  end
end
