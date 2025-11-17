require "open-uri"

class ScrapeJob < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(url:, which_page:)
    browser = Ferrum::Browser.new(browser_options: { "no-sandbox": nil })
    page = browser.create_page
    page.go_to(url)

    receipes = page.css("#az-recipes-#{which_page}-recipes > div > div")

    return if receipes.blank?

    counter = 0

    while counter < receipes.count do
      link = receipes[counter].css("a").first
      image = receipes[counter].css("img").first

      if image.nil?
        counter += 1
        next
      end

      page.go_to("https://www.bbc.co.uk#{link.attribute(:href)}")

      if Receipe.where(url: page.url).any?
        counter += 1
        next
      end

      save_record(page)

      page.back

      counter += 1
      receipes = page.css("#az-recipes-#{which_page}-recipes > div > div")
    end
    browser.quit
  end

private

  def save_record(page)
    attributes = { status: :published }
    attributes.merge!(name(page))
    attributes.merge!(info(page))
    attributes.merge!(description(page))
    attributes.merge!(instructions(page))
    attributes.merge!(url: page.url)
    image_url = page.at_css("img")&.attribute("src")
    receipe_ingredients = receipe_ingredients_attributes(page)

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

  def name(page)
    {
      name: page.at_css(".ssrcss-pbttu9-Heading").text
    }
  end

  def info(page)
    result = {}
    receipe_info = page.at_css(".ssrcss-7o8aib-Wrapper")
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

  def description(page)
    description = page.at_css("p[data-testid='recipe-description']")&.text
    { description: description.presence }
  end

  def instructions(page)
    result = { instructions_attributes: {} }
    instructions = page.at_css(".ssrcss-1o787j8-OrderedList")
    children = instructions.css(":scope > *")

    children.each_with_index.map do |child, index|
      result[:instructions_attributes][index] = {
        step: index,
        body: child.text
      }
    end
    result
  end

  def receipe_ingredients_attributes(page)
    result = { receipe_ingredients_attributes: {} }
    ingredient_element = page.at_css(".ssrcss-5tl2t9-Wrapper")
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
