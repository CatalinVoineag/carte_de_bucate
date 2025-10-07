class AddTypeToReceipe < ActiveRecord::Migration[8.0]
  def change
    add_column :receipes, :type, :string, null: false
  end
end
