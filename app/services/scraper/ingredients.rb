require "open-uri"

module Scraper
  class Ingredients
    attr_reader :url
    Struct = Data.define(:name, :image_url)

    def initialize(url:)
      @url = url
    end

    def self.call(url: nil)
      urls = [
        "https://www.bbc.co.uk/food/ingredients/a-z/a/1#featured-content"
      ]

      urls.each do |url|
        new(url:).call
      end
    end

    def call
      browser = Ferrum::Browser.new
      browser.go_to(url)

      content = browser.at_css("#az-ingredients-a-recipes > div")
      ingredients = content.css(":scope .promo__ingredient")

      structs = ingredients.map do |ingredient|
        Struct.new(
          name: ingredient.css(":scope .promo__title").first.text,
          image_url: ingredient.css(":scope img").first&.attribute("src")
        )
      end

      browser.quit

      ActiveRecord::Base.transaction do
        names_in_db = Ingredient.where(name: structs.map(&:name)).pluck(:name)
        valid_structs = structs.reject { |struct| names_in_db.include?(struct.name) }

        valid_structs.each do |struct|
          ingredient = Ingredient.new(name: struct.name)

          if struct.image_url.present?
            io = URI.open(struct.image_url)

            ingredient.image.attach(
              io: io,
              filename: File.basename(io.path),
              content_type: io.content_type
            )
          end
          ingredient.save!
        end
      end
    end
  end
end
