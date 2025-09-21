class CreateReceipeIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :receipe_ingredients do |t|
      t.references :receipe, null: false, foreign_key: { on_delete: :cascade }
      t.references :ingredient, null: false, foreign_key: { on_delete: :cascade }
      t.integer :quantity, null: false
      t.integer :grams

      t.timestamps
    end
  end
end
