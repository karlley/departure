class FavoritesController < ApplicationController
  before_action :logged_in_user

  def index
    @favorites = current_user.favorites
    # いいね!したdestinations を取得
    # applications_controller#search_result @destinations をお気に入りの値に上書き
    @destinations = current_user.favorite_destinations.paginate(page: params[:page], per_page: 12)
    # applications_controler#search_result @markers をお気に入りの値に上書き
    @markers = Gmaps4rails.build_markers(@destinations) do |destination, marker|
      marker.lat(destination.latitude)
      marker.lng(destination.longitude)
      marker.infowindow render_to_string(partial: "destinations/map_infowindow", locals: { destination: destination })
    end
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
      # お気に入りはnotification_type の種別は1
      @user.notifications.create(destination_id: @destination.id, notification_type: 1, from_user_id: current_user.id)
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
