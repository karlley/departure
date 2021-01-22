class ChangeDefaultToDestinations < ActiveRecord::Migration[5.2]
  def change
    change_column_default :destinations, :expense, from: "0", to: nil
  end
end
