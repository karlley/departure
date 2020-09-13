class AddColumnToDestinations < ActiveRecord::Migration[5.2]
  def change
    add_column :destinations, :address, :string
  end
end
