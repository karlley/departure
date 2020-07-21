class AddPictureToDestinations < ActiveRecord::Migration[5.2]
  def change
    add_column :destinations, :picture, :string
  end
end
