class AddUrlToReceipe < ActiveRecord::Migration[8.0]
  def change
    add_column :receipes, :url, :string
  end
end
