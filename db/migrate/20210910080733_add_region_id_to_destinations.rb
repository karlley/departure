class AddRegionIdToDestinations < ActiveRecord::Migration[5.2]
  def change
    add_column :destinations, :region_id, :integer
  end
end
