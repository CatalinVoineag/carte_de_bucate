class CreateReceipes < ActiveRecord::Migration[8.0]
  def change
    create_table :receipes do |t|
      t.string :name
      t.text :description
      t.text :instructions
      t.string :prep_time
      t.string :cook_time
      t.string :servings
      t.string "tags", array: true

      t.timestamps
    end
  end
end
