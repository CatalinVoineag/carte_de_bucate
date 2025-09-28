require "open-uri"

module Scraper
  class Ingredients
    attr_accessor :url
    Struct = Data.define(:name, :image_url)

    def initialize
      @url = "https://www.bbc.co.uk/food/ingredients/a-z/a/1#featured-content"
    end

    def self.call
      new.call
    end

    def call
      browser = Ferrum::Browser.new
      browser.go_to(url)
      pagination = browser.at_css(".pagination__list")
      pagination_items = pagination.css(":scope > *")
      number_of_pages = pagination_items[pagination_items.size - 2].text.to_i
      structs = []

      if number_of_pages > 0
        number_of_pages.times do |number|
          number += 1

          if number > 1
            @url = "https://www.bbc.co.uk/food/ingredients/a-z/a/#{number}#featured-content"
          end

          structs += scrape(browser:, load_page: number > 1)
        end
      end

      browser.quit
      save_structs!(structs)
    end

    def scrape(browser:, load_page:)
      if load_page == true
        browser = Ferrum::Browser.new
        browser.go_to(url)
      end

      content = browser.at_css("#az-ingredients-a-recipes > div")
      ingredients = content.css(":scope .promo__ingredient")

      ingredients.map do |ingredient|
        Struct.new(
          name: ingredient.css(":scope .promo__title").first.text,
          image_url: ingredient.css(":scope img").first&.attribute("src")
        )
      end
    end

    def save_structs!(structs)
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
