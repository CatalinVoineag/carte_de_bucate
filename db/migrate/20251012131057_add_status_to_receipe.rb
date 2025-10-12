class AddStatusToReceipe < ActiveRecord::Migration[8.0]
  def change
    add_column :receipes, :status, :string, null: false
  end
end
