class RemoveCountryIdFromCountries < ActiveRecord::Migration[5.2]
  def change
    remove_column :countries, :country_id, :integer
  end
end
