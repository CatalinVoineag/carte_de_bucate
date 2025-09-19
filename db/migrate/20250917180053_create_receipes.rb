class CreateReceipes < ActiveRecord::Migration[8.0]
  def change
    create_table :receipes do |t|
      t.string :name
      t.text :description
      t.text :instructions

      t.timestamps
    end
  end
end
