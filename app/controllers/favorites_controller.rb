class FavoritesController < ApplicationController
  before_action :logged_in_user

  def index
    @favorites = current_user.favorites
  end

  def create
    @destination = Destination.find(params[:destination_id])
    @user = @destination.user
    current_user.favorite(@destination)
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
    # 自分以外のユーザーからお気に入り登録が発生すると通知を作成
    if @user != current_user
      # お気に入りはtype 種別は1
      @user.notifications.create(destination_id: @destination.id, type: 1, from_user_id: current_user.id)
      @user.update_attribute(:notification, true)
    end
  end

  def destroy
    @destination = Destination.find(params[:destination_id])
    current_user.favorites.find_by(destination_id: @destination.id).destroy
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
  end
end
