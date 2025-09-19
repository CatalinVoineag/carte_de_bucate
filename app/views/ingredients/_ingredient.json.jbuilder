json.extract! ingredient, :id, :name, :quantity, :receipe_id, :created_at, :updated_at
json.url ingredient_url(ingredient, format: :json)
