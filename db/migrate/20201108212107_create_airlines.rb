class CreateAirlines < ActiveRecord::Migration[5.2]
  def change
    create_table :airlines do |t|
      t.string :airline_name
      t.integer :country_id
      t.string :alliance
      t.integer :alliance_type

      t.timestamps
    end
  end
end
