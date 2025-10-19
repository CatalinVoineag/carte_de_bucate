require "open-uri"

class ScraperOld
  attr_reader :url

  def initialize(url:)
    @url = url
  end

  def self.call(url: nil)
    urls = [
      "https://www.bbc.co.uk/food/recipes/pretzels_71296",
      "https://www.bbc.co.uk/food/recipes/basicpancakeswithsuga_66226",
      "https://www.bbc.co.uk/food/recipes/creamy_gochujang_pasta_59347",
      "https://www.bbc.co.uk/food/recipes/vegan_pulled_jackfruit_17371",
      "https://www.bbc.co.uk/food/recipes/fragrant_noodle_bowl_22856",
      "https://www.bbc.co.uk/food/recipes/freshpastadough_3067"
    ]

    urls.each do |url|
      new(url:).call
    end
  end

  def call
    attributes = { status: :published }
    browser = Ferrum::Browser.new
    browser.go_to(url)

    attributes.merge!(name(browser))
    attributes.merge!(info(browser))
    attributes.merge!(description(browser))
    attributes.merge!(instructions(browser))
    image_url = browser.at_css("img")&.attribute("src")
    receipe_ingredients = receipe_ingredients_attributes(browser)

    browser.quit

    ActiveRecord::Base.transaction do
      # there is logic to not duplicate the records in Receipe model
      # That's why we need to create ingredients one by one
      first_receipe_ingredient = receipe_ingredients[:receipe_ingredients_attributes].delete(0)

      attributes.merge!(receipe_ingredients_attributes: { 0 => first_receipe_ingredient })
      receipe = GlobalReceipe.create!(attributes.with_indifferent_access)

      receipe_ingredients[:receipe_ingredients_attributes].each do |key, value|
        receipe.update!(
          { receipe_ingredients_attributes: { key => value } }.with_indifferent_access
        )
      end

      io = URI.open(image_url)
      receipe.image.attach(
        io: io,
        filename: File.basename(io.path),
        content_type: io.content_type
      )

      receipe.save!
    end
  end

  private

  def name(browser)
    {
      name: browser.at_css(".ssrcss-pbttu9-Heading").text
    }
  end

  def info(browser)
    result = {}
    receipe_info = browser.at_css(".ssrcss-fzx4as-Wrapper")
    if receipe_info.nil?
      receipe_info = browser.at_css(".ssrcss-9nk17b-Wrapper ")
    end
    children = receipe_info.css(":scope > *")

    children.each_with_index.map do |child, index|
      if index == 0
        result[:prep_time] = child.text.gsub("Prepare", "").strip
      elsif index == 1
        result[:cook_time] = child.text.gsub("Cook", "").strip
      elsif index == 2
        # result[:servings] = child.text.gsub("Serve", "").strip
        result[:servings] = child.css(":scope > *").last.text
      elsif index == 3
        result[:tags] = child.text.gsub("Dietary", "").split(/(?=[A-Z])/)
      end
    end

    result
  end

  def description(browser)
    description = browser.at_css(".ssrcss-19e4ohh-StyledHtmlParser").text
    { description: }
  end

  def instructions(browser)
    result = { instructions_attributes: {} }
    instructions = browser.at_css(".ssrcss-1o787j8-OrderedList")
    children = instructions.css(":scope > *")

    children.each_with_index.map do |child, index|
      result[:instructions_attributes][index] = {
        step: index,
        body: child.text
      }
    end
    result
  end

  def receipe_ingredients_attributes(browser)
    result = { receipe_ingredients_attributes: {} }
    ingredient_element = browser.at_css(".ssrcss-5tl2t9-Wrapper")
    ingredients = ingredient_element.css(":scope > div > ul > li")

    ingredients.each_with_index do |ingredient_element, index|
      anchor_ingredient = ingredient_element.css("a")&.first&.text
      db_ingredient = Ingredient.search_by_name(anchor_ingredient)&.first&.name
      ingredient_name = db_ingredient || anchor_ingredient

      notes = nil
      text = ingredient_element.text.strip

      if text =~ /^\s*([\d\/\.]+(?:\s*\d+\/\d+)?)([a-zA-Z]+)?(?:\/[^\s]+(?:\s*\d+[a-zA-Z]+)*)?\s*(.+)$/
        quantity = $1.strip
        unit = ($2 || "").strip
        rest = $3.gsub("oz ", "").gsub(/\/\dfl/, "").gsub("’00’", "").strip

        if anchor_ingredient.nil? && ingredient_name.nil?
          first_word = rest.split.first
          ingredient_name = Ingredient.search_by_name(first_word)&.first&.name
        end

        if unit.blank? && rest =~ /^?(tbsp|tsp)\s*(.+)$/
          unit = $1.strip
          rest = $2.strip
        end

        if ingredient_name.present?
          notes = rest.downcase == ingredient_name ? nil : rest.gsub(ingredient_name, "${}")
          name = ingredient_name
        else
          name = rest
        end
      else
        # fallback: no explicit quantity/unit
        quantity = ""
        unit = ""
        rest = text

        if ingredient_name.present?
          notes = rest.downcase == ingredient_name ? nil : rest.gsub(ingredient_name, "${}")
          name = ingredient_name
        else
          name = rest
        end
      end

      result[:receipe_ingredients_attributes][index] = {
        quantity:,
        unit:,
        notes:,
        ingredient_attributes: { name: }
      }
    end

    result
  end
end
