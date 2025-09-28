class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name, index: { unique: true, name: "unique_receipe_name" }

      t.timestamps
    end
  end
end
