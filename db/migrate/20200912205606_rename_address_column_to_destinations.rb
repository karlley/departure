class RenameAddressColumnToDestinations < ActiveRecord::Migration[5.2]
  def change
    rename_column :destinations, :address, :spot
  end
end
