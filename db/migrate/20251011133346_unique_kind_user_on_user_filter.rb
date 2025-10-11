class UniqueKindUserOnUserFilter < ActiveRecord::Migration[8.0]
  def change
    add_index :user_filters, [ :user_id, :kind ], unique: true
  end
end
