class CreateUserFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :user_filters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind
      t.jsonb :filters, default: {}
      t.integer :pagination_page

      t.timestamps
    end
  end
end
