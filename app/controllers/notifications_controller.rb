class NotificationsController < ApplicationController
  before_action :logged_in_user

  def index
    # current_user の通知を取得
    @notifications = current_user.notifications
    # Notifications ページで通知確認後に通知フラグを削除
    current_user.update_attribute(:notification, false)
  end
end
