require "open-uri"

module Scraper
  class Receipes
    attr_accessor :url, :pages
    Struct = Data.define(:name, :image_url)

    def initialize
      @pages = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
                 "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "y",
                 "z", "0-9" ]
    end

    def self.call
      new.call
    end

    def call
      browser = Ferrum::Browser.new(browser_options: { "no-sandbox": nil }, process_timeout: 30)

      pages.each do |which_page|
        @url = "https://www.bbc.co.uk/food/recipes/a-z/#{which_page}/1#featured-content"
        page = browser.create_page
        page.go_to(@url)
        pagination = browser.at_css(".pagination__list")

        if pagination.nil?
          number_of_pages = 1
        else
          pagination_items = pagination.css(":scope > *")
          number_of_pages = pagination_items[pagination_items.size - 2].text.to_i
        end

        if number_of_pages > 0
          number_of_pages.times do |number|
            number += 1

            if number > 1
              puts "PAGE #{which_page}"
              puts "number #{number}"

              @url = "https://www.bbc.co.uk/food/recipes/a-z/#{which_page}/#{number}#featured-content"
            end

            ScrapeJob.perform_later(url: @url, which_page:)
          end
        end
      end

      browser.quit
    end
  end
end
