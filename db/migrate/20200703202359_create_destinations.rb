class CreateDestinations < ActiveRecord::Migration[5.2]
  def change
    create_table :destinations do |t|
      t.string :name
      t.string :country
      t.text :description
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :destinations, [:user_id, :created_at]
  end
end
