class Scraper
  attr_reader :url

  def initialize(url:)
    @url = url
  end

  def self.call(url: nil)
    urls = [
      "https://www.bbc.co.uk/food/recipes/pretzels_71296",
      "https://www.bbc.co.uk/food/recipes/prawn_and_ginger_wontons_92941",
      "https://www.bbc.co.uk/food/recipes/proper_baked_beans_with_36013",
      "https://www.bbc.co.uk/food/recipes/basicpancakeswithsuga_66226"
    ]

    urls.each do |url|
      new(url:).call
      sleep(0.5)
    end
  end

  def call
    attributes = {}
    browser = Ferrum::Browser.new
    browser.go_to(url)

    attributes.merge!(name(browser))
    attributes.merge!(info(browser))
    attributes.merge!(description(browser))
    attributes.merge!(instructions(browser))
    attributes.merge!(receipe_ingredients_attributes(browser))

    browser.quit

    Receipe.create!(attributes.with_indifferent_access)
  end

  private

  def name(browser)
    {
      name: browser.at_css(".ssrcss-pbttu9-Heading").text
    }
  end

  ## Remove the word oz from ingredients

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
        result[:servings] = child.text.gsub("Serve", "").strip
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
    result = { instructions: "" }
    instructions = browser.at_css(".ssrcss-1o787j8-OrderedList")
    children = instructions.css(":scope > *")

    children.each_with_index.map do |child, index|
      result[:instructions].concat(
        "#{index + 1}. #{child.text}",
      )
    end

    result
  end

  def receipe_ingredients_attributes(browser)
    result = { receipe_ingredients_attributes: {} }
    ingredient_element = browser.at_css(".ssrcss-5tl2t9-Wrapper")
    ingredients = ingredient_element.css(":scope > div > ul > li")

    ingredients.each_with_index do |ingredient, index|
      #ingredient.text.include?(ingredient.css(":scope > a").first.text)
      if ingredient.text =~ /^\s*([\d\/\.]+(?:\s*\d+\/\d+)?)([a-zA-Z]+)?(?:\/[^\s]+(?:\s*\d+[a-zA-Z]+)*)?\s*(.+)$/
        quantity = $1.strip
        unit = ($2 || "").strip
        name = $3.gsub("oz ", "").gsub(/\/\dfl/, "").strip
      else
        # fallback: no explicit quantity/unit
        quantity = ""
        unit = ""
        name = ingredient.text.strip
      end

      result[:receipe_ingredients_attributes][index] = {
        quantity:,
        unit:,
        ingredient_attributes: { name: name }
      }
    end

    result
  end
end
