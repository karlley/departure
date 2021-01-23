class ChangeDefaultToDestinationsAgain < ActiveRecord::Migration[5.2]
  def change
    change_column_default :destinations, :expense, from: nil, to: "0"
  end
end
