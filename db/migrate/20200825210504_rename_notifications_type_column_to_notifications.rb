class RenameNotificationsTypeColumnToNotifications < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :notifications_type, :notification_type
  end
end
