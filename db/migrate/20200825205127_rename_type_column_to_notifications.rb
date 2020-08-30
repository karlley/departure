class RenameTypeColumnToNotifications < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :type, :notifications_type
  end
end
