class RemoveAirlineFromDestinations < ActiveRecord::Migration[5.2]
  def change
    remove_column :destinations, :airline, :string
  end
end
