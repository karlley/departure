class RemoveCountryFromDestinations < ActiveRecord::Migration[5.2]
  def change
    remove_column :destinations, :country, :string
  end
end
