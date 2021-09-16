class AddNotnullAndDefaultToExpenseOnDestinations < ActiveRecord::Migration[5.2]
  def change
    change_column :destinations, :expense, :integer, default: 0, null: false
  end
end
