class AddUserToReceipe < ActiveRecord::Migration[8.0]
  def change
    add_reference(
      :receipes,
      :user,
      null: :true,
      foreign_key: { on_delete: :cascade },
    )
  end
end
