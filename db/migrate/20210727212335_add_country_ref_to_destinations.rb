class AddCountryRefToDestinations < ActiveRecord::Migration[5.2]
  def change
    add_reference :destinations, :country, foreign_key: true
  end
end
