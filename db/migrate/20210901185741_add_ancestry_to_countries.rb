class AddAncestryToCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :ancestry, :string
    add_index :countries, :ancestry
  end
end
