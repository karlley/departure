class AddColumnToDestinationsForDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :destinations, :expense, :integer
    add_column :destinations, :season, :integer
    add_column :destinations, :experience, :string
    add_column :destinations, :airline, :string
    add_column :destinations, :food, :string
  end
end
