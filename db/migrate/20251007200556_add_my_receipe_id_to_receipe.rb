class AddMyReceipeIdToReceipe < ActiveRecord::Migration[8.0]
  def change
    add_reference(
      :receipes,
      :global_receipe,
      null: true,
      foreign_key: { to_table: :receipes }
    )
  end
end
