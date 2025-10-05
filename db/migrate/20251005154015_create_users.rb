class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true, name: "unique_emails" }

      t.timestamps
    end
  end
end
