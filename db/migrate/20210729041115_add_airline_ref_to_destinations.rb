class AddAirlineRefToDestinations < ActiveRecord::Migration[5.2]
  def change
    add_reference :destinations, :airline, foreign_key: true
  end
end
