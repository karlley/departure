class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :destination_id
      t.text :content

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :destination_id
  end
end
