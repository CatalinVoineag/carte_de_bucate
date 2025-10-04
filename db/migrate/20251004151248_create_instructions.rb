class CreateInstructions < ActiveRecord::Migration[8.0]
  def change
    create_table :instructions do |t|
      t.references :receipe, null: false, foreign_key: { on_delete: :cascade }
      t.integer :step, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
