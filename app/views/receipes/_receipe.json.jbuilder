json.extract! receipe, :id, :name, :description, :instructions, :created_at, :updated_at
json.url receipe_url(receipe, format: :json)
