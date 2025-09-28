module Scraper
  class Ingredients
    attr_reader :url

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

      # Put in images as well
      content = browser.at_css("#az-ingredients-a-recipes > div")
      headers = content.css(":scope .promo__title")
      header_names = headers.map { |name| name.text.downcase }
      browser.quit

      ActiveRecord::Base.transaction do
        names_in_db = Ingredient.where(name: header_names).pluck(:name)
        ingredient_names = header_names - names_in_db

        if ingredient_names.any?
          Ingredient.insert_all!(
            ingredient_names.map { |name| { name: name } }
          )
        end
      end
    end
  end
end
