module NotificationsHelper
  # 通知元のユーザを取得
  def get_user_for_notification(notification)
    User.find(notification.from_user_id)
  end

  # 通知元の旅先を取得
  def get_destination_for_notification(notification)
    Destination.find(notification.destination_id)
  end
end
