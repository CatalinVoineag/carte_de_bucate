# Dummy data for local development. Safe to run repeatedly: existing records are kept.
class DevSeeder
  IMAGES = Dir[Rails.root.join("db/seeds/images/*.jpg").to_s].sort.freeze

  # [quantity, unit, ingredient name, notes] - notes may use "${}" to show the ingredient name
  GLOBAL_RECEIPES = [
    {
      name: "Classic spaghetti carbonara",
      description: "A silky Roman pasta made with egg, pecorino and crisp guanciale. No cream needed.",
      prep_time: "10 mins", cook_time: "20 mins", servings: "Serves 4", tags: [ "Quick" ],
      ingredients: [
        [ "400", "g", "spaghetti", nil ],
        [ "150", "g", "guanciale", "cut into lardons" ],
        [ "3", nil, "egg yolks", nil ],
        [ "1", nil, "egg", nil ],
        [ "80", "g", "pecorino", "finely grated" ],
        [ "1", "tsp", "black pepper", "freshly ground" ]
      ],
      instructions: [
        "Bring a large pan of salted water to the boil and cook the spaghetti until al dente.",
        "Fry the guanciale in a dry pan until crisp and the fat has rendered.",
        "Whisk the eggs, yolks, pecorino and pepper together in a bowl.",
        "Drain the pasta, reserving a cup of the cooking water, and toss it with the guanciale off the heat.",
        "Add the egg mixture with a splash of pasta water, stirring fast, until creamy. Serve immediately."
      ]
    },
    {
      name: "Speedy vegetable curry",
      description: "A weeknight curry with chickpeas, spinach and a gentle coconut sauce.",
      prep_time: "10 mins", cook_time: "25 mins", servings: "Serves 4", tags: [ "Vegan", "Vegetarian", "Gluten-free" ],
      ingredients: [
        [ "2", "tbsp", "olive oil", nil ],
        [ "1", nil, "onion", "finely chopped" ],
        [ "2", "cloves", "garlic", "crushed" ],
        [ "2", "tsp", "ground cumin", nil ],
        [ "400", "g", "chickpeas", "drained and rinsed" ],
        [ "400", "ml", "coconut milk", nil ],
        [ "100", "g", "spinach", nil ]
      ],
      instructions: [
        "Soften the onion in the oil for 5 minutes.",
        "Add the garlic and cumin and cook for a minute more.",
        "Stir in the chickpeas and coconut milk and simmer for 15 minutes.",
        "Fold in the spinach until wilted and serve with rice."
      ]
    },
    {
      name: "Lemon and herb roast chicken",
      description: "A whole chicken roasted with lemon, garlic and thyme until the skin is golden.",
      prep_time: "15 mins", cook_time: "75 mins", servings: "Serves 6", tags: [ "Gluten-free", "Healthy" ],
      ingredients: [
        [ "1.6", "kg", "whole chicken", nil ],
        [ "1", nil, "lemon", "halved" ],
        [ "4", "cloves", "garlic", "unpeeled" ],
        [ "3", "sprigs", "thyme", nil ],
        [ "2", "tbsp", "butter", "softened" ],
        [ "1", "tsp", "sea salt", nil ]
      ],
      instructions: [
        "Heat the oven to 200°C (180°C fan).",
        "Rub the chicken with butter and salt, and stuff the cavity with lemon, garlic and thyme.",
        "Roast for about 75 minutes, until the juices run clear.",
        "Rest for 10 minutes before carving."
      ]
    },
    {
      name: "Blueberry pancakes",
      description: "Fluffy weekend pancakes studded with blueberries.",
      prep_time: "10 mins", cook_time: "15 mins", servings: "Makes 8", tags: [ "Dessert", "Vegetarian" ],
      ingredients: [
        [ "200", "g", "plain flour", nil ],
        [ "2", "tsp", "baking powder", nil ],
        [ "2", nil, "eggs", "beaten" ],
        [ "250", "ml", "milk", nil ],
        [ "2", "tbsp", "sugar", nil ],
        [ "100", "g", "blueberries", nil ]
      ],
      instructions: [
        "Whisk the flour, baking powder and sugar together.",
        "Beat in the eggs and milk until just smooth.",
        "Fold in the blueberries.",
        "Spoon into a hot, lightly oiled pan and cook until bubbles form, then flip."
      ]
    },
    {
      name: "Beef chilli con carne",
      description: "A slow-cooked chilli with beef mince, kidney beans and smoked paprika.",
      prep_time: "15 mins", cook_time: "60 mins", servings: "Serves 6", tags: [ "Healthy" ],
      ingredients: [
        [ "500", "g", "beef mince", nil ],
        [ "1", nil, "onion", "diced" ],
        [ "1", "tbsp", "smoked paprika", nil ],
        [ "400", "g", "tomatoes", "chopped" ],
        [ "400", "g", "kidney beans", "drained" ],
        [ "1", "tbsp", "tomato purée", nil ]
      ],
      instructions: [
        "Brown the mince in a heavy pan, then remove it.",
        "Soften the onion and paprika in the same pan.",
        "Return the beef, add the tomatoes and purée, and simmer for 45 minutes.",
        "Stir in the beans and cook for 10 minutes more."
      ]
    },
    {
      name: "Tomato and basil bruschetta",
      description: "Toasted sourdough topped with ripe tomatoes, garlic and fresh basil.",
      prep_time: "10 mins", cook_time: "5 mins", servings: "Serves 4", tags: [ "Quick", "Vegan", "Vegetarian" ],
      ingredients: [
        [ "4", "slices", "sourdough", nil ],
        [ "3", nil, "tomatoes", "diced" ],
        [ "1", "clove", "garlic", "halved" ],
        [ "1", "small bunch", "basil", "torn" ],
        [ "2", "tbsp", "olive oil", nil ]
      ],
      instructions: [
        "Toast the sourdough until golden.",
        "Rub each slice with the cut garlic.",
        "Mix the tomatoes, basil and oil, and spoon over the toast."
      ]
    },
    {
      name: "Sticky gingerbread cake",
      description: "A dark, sticky loaf cake with treacle and warming ginger.",
      prep_time: "15 mins", cook_time: "50 mins", servings: "Serves 10", tags: [ "Dessert", "Vegetarian" ],
      ingredients: [
        [ "175", "g", "butter", nil ],
        [ "100", "g", "dark brown sugar", nil ],
        [ "3", "tbsp", "golden syrup", nil ],
        [ "2", "tsp", "ground ginger", nil ],
        [ "200", "g", "plain flour", nil ],
        [ "2", nil, "eggs", nil ],
        [ "150", "ml", "milk", nil ]
      ],
      instructions: [
        "Heat the oven to 160°C and line a loaf tin.",
        "Melt the butter, sugar and syrup, then cool slightly.",
        "Whisk in the eggs, milk, flour and ginger.",
        "Bake for 50 minutes until a skewer comes out clean."
      ]
    },
    {
      name: "Miso glazed salmon",
      description: "Salmon fillets glazed with miso, mirin and soy and grilled until sticky.",
      prep_time: "5 mins", cook_time: "12 mins", servings: "Serves 2", tags: [ "Quick", "Healthy", "Gluten-free" ],
      ingredients: [
        [ "2", nil, "salmon fillets", nil ],
        [ "2", "tbsp", "white miso", nil ],
        [ "1", "tbsp", "mirin", nil ],
        [ "1", "tsp", "soy sauce", "gluten-free if needed" ],
        [ "1", "tsp", "honey", nil ]
      ],
      instructions: [
        "Mix the miso, mirin, soy and honey into a glaze.",
        "Brush the salmon with the glaze and leave for 10 minutes.",
        "Grill for 6 to 8 minutes until cooked through and sticky."
      ]
    },
    {
      name: "Mushroom risotto",
      description: "A creamy arborio risotto with mushrooms and parmesan.",
      prep_time: "10 mins", cook_time: "35 mins", servings: "Serves 4", tags: [ "Vegetarian" ],
      ingredients: [
        [ "300", "g", "arborio rice", nil ],
        [ "250", "g", "mushrooms", "sliced" ],
        [ "1", nil, "onion", "finely chopped" ],
        [ "1", "litre", "vegetable stock", "kept warm" ],
        [ "50", "g", "parmesan", "grated" ],
        [ "30", "g", "butter", nil ]
      ],
      instructions: [
        "Fry the mushrooms in half the butter until golden, then set aside.",
        "Soften the onion, add the rice and stir for 2 minutes.",
        "Add the stock a ladle at a time, stirring until absorbed, for about 20 minutes.",
        "Stir in the mushrooms, remaining butter and parmesan, and serve."
      ]
    },
    {
      name: "Fish tacos with lime slaw",
      description: "Crispy white fish in soft tortillas with a crunchy lime slaw.",
      prep_time: "15 mins", cook_time: "10 mins", servings: "Serves 4", tags: [ "Quick", "Healthy" ],
      ingredients: [
        [ "400", "g", "white fish fillets", nil ],
        [ "8", nil, "corn tortillas", nil ],
        [ "200", "g", "red cabbage", "shredded" ],
        [ "1", nil, "lime", "juiced" ],
        [ "1", "tsp", "ground cumin", nil ]
      ],
      instructions: [
        "Toss the cabbage with lime juice and a pinch of salt for the slaw.",
        "Dust the fish with cumin and fry for 3 to 4 minutes each side.",
        "Warm the tortillas and fill with fish and slaw."
      ]
    },
    {
      name: "Greek village salad",
      description: "Crunchy cucumber, tomato, red onion and feta with a simple oregano dressing.",
      prep_time: "10 mins", cook_time: "0 mins", servings: "Serves 4", tags: [ "Vegetarian", "Gluten-free", "Quick" ],
      ingredients: [
        [ "3", nil, "tomatoes", "cut into wedges" ],
        [ "1", nil, "cucumber", "sliced" ],
        [ "1", nil, "red onion", "thinly sliced" ],
        [ "150", "g", "feta", nil ],
        [ "3", "tbsp", "olive oil", nil ],
        [ "1", "tsp", "dried oregano", nil ]
      ],
      instructions: [
        "Combine the tomatoes, cucumber and onion in a bowl.",
        "Add the feta in one piece on top.",
        "Drizzle with oil and oregano and serve."
      ]
    },
    {
      name: "Honey garlic chicken thighs",
      description: "Sticky chicken thighs baked with honey, garlic and a squeeze of lemon.",
      prep_time: "10 mins", cook_time: "35 mins", servings: "Serves 4", tags: [ "Healthy", "Gluten-free" ],
      ingredients: [
        [ "8", nil, "chicken thighs", "skin on" ],
        [ "3", "tbsp", "honey", nil ],
        [ "3", "cloves", "garlic", "minced" ],
        [ "1", nil, "lemon", "juiced" ],
        [ "1", "tbsp", "soy sauce", nil ]
      ],
      instructions: [
        "Heat the oven to 200°C.",
        "Mix the honey, garlic, lemon and soy and coat the chicken.",
        "Bake for 35 minutes, basting halfway, until cooked through."
      ]
    }
  ].freeze

  # Receipes the cook has created: published ones are copied into the public list
  OWN_RECEIPES = [
    {
      name: "Grandma's lentil soup",
      description: "A thick, comforting soup with red lentils, carrot and cumin.",
      prep_time: "10 mins", cook_time: "30 mins", servings: "Serves 4", tags: [ "Vegan", "Healthy" ],
      publish: true,
      ingredients: [
        [ "200", "g", "red lentils", "rinsed" ],
        [ "1", nil, "onion", "chopped" ],
        [ "2", nil, "carrots", "diced" ],
        [ "1", "tsp", "ground cumin", nil ],
        [ "1", "litre", "vegetable stock", nil ]
      ],
      instructions: [
        "Soften the onion and carrots in a little oil.",
        "Add the cumin, lentils and stock, and simmer for 25 minutes.",
        "Blend until smooth and season."
      ]
    },
    {
      name: "Sunday pancake stack",
      description: "Thin pancakes served with maple syrup and sliced banana.",
      prep_time: "5 mins", cook_time: "15 mins", servings: "Serves 2", tags: [ "Vegetarian", "Dessert" ],
      publish: true,
      ingredients: [
        [ "150", "g", "plain flour", nil ],
        [ "1", nil, "egg", nil ],
        [ "200", "ml", "milk", nil ],
        [ "2", "tbsp", "maple syrup", nil ],
        [ "1", nil, "banana", "sliced" ]
      ],
      instructions: [
        "Whisk the flour, egg and milk into a smooth batter.",
        "Cook small spoonfuls in a hot pan.",
        "Stack with banana and drizzle with maple syrup."
      ]
    },
    {
      name: "Weekend pancakes (work in progress)",
      description: nil,
      prep_time: "5 mins", cook_time: nil, servings: nil, tags: [],
      publish: false,
      ingredients: [],
      instructions: []
    }
  ].freeze

  def self.call(reset: false)
    new.call(reset:)
  end

  def call(reset: false)
    abort "dev:seed is not allowed in production" if Rails.env.production?

    # Each record is saved on its own so uploaded images are on disk before they are copied
    ActiveRecord::Base.transaction { clear_everything } if reset

    # The cook is created last so User.last (the current user in this app) is the demo user
    User.find_or_create_by!(email: "alice@example.com")
    cook = User.find_or_create_by!(email: "cook@example.com")

    globals = seed_global_receipes
    seed_saved_receipes(cook, globals)
    seed_own_receipes(cook)

    ActiveStorage::Blob.unattached.find_each(&:purge) if reset
    summary
  end

  private

  def clear_everything
    UserFilter.delete_all
    MyReceipe.destroy_all
    GlobalReceipe.destroy_all
    Ingredient.destroy_all
    User.destroy_all
  end

  def seed_global_receipes
    GLOBAL_RECEIPES.each_with_index.map do |data, index|
      receipe = GlobalReceipe.find_or_initialize_by(name: data[:name])
      next receipe if receipe.persisted?

      fill_receipe(receipe, data, status: "published")
      attach_image(receipe, index) unless receipe.image.attached?
      receipe.save!
      receipe
    end
  end

  def seed_saved_receipes(cook, globals)
    globals.first(3).each do |global|
      next if cook.my_receipes.exists?(global_receipe_id: global.id)

      ReceipeService::User.save(receipe: global, user: cook)
    end
  end

  # Receipes the cook created in the Receipes tab. Published ones are also saved to the cook's My receipes.
  def seed_own_receipes(cook)
    OWN_RECEIPES.each_with_index do |data, index|
      receipe = GlobalReceipe.find_or_initialize_by(name: data[:name], user_id: cook.id)
      next if receipe.persisted? && receipe.published? == data[:publish]

      status = data[:publish] ? "published" : "draft"
      fill_receipe(receipe, data, status:)
      receipe.author = cook
      attach_image(receipe, index) unless receipe.image.attached?
      receipe.save!(context: data[:publish] ? :publish : :draft)

      ReceipeService::User.save(receipe:, user: cook) if data[:publish]
    end
  end

  def fill_receipe(receipe, data, status:)
    receipe.assign_attributes(
      description: data[:description],
      prep_time: data[:prep_time],
      cook_time: data[:cook_time],
      servings: data[:servings],
      tags: data[:tags],
      status:
    )

    receipe.receipe_ingredients = data[:ingredients].map do |quantity, unit, ingredient_name, notes|
      ReceipeIngredient.new(
        ingredient: Ingredient.find_or_create_by!(name: ingredient_name),
        quantity:,
        unit:,
        notes:
      )
    end

    receipe.instructions = data[:instructions].each_with_index.map do |body, index|
      Instruction.new(step: index + 1, body:)
    end
  end

  def attach_image(receipe, index)
    path = IMAGES[index % IMAGES.size]
    receipe.image.attach(
      io: StringIO.new(File.binread(path)),
      filename: File.basename(path),
      content_type: "image/jpeg"
    )
  end

  def summary
    puts "Dev data ready:"
    puts "  users:               #{User.count}"
    puts "  ingredients:         #{Ingredient.count}"
    puts "  receipes (Receipes): #{GlobalReceipe.published.count} published, #{GlobalReceipe.draft.count} draft"
    puts "  receipes (My receipes): #{MyReceipe.count}"
  end
end
