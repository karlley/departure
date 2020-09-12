class DestinationsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update]

  def show
    @destination = Destination.find(params[:id])
    @comment = Comment.new
    # GoogleMap 表示用のマーカーを作成
    @marker = Gmaps4rails.build_markers(@destination) do |destination, marker|
      marker.lat(destination.latitude)
      marker.lng(destination.longitude)
      marker.infowindow render_to_string(partial: "destinations/map_infowindow", locals: {destination: destination})
    end
  end

  def new
    @destination = Destination.new
  end

  def create
    @destination = current_user.destinations.build(destination_params)
    if @destination.save
      flash[:success] = "Destination added!"
      redirect_to destination_path(@destination)
    else
      render 'destinations/new'
    end
  end

  def edit
    @destination = Destination.find(params[:id])
  end

  def update
    @destination = Destination.find(params[:id])
    if @destination.update_attributes(destination_params)
      flash[:success] = "Destination updated!"
      redirect_to @destination
    else
      render 'edit'
    end
  end

  def destroy
    @destination = Destination.find(params[:id])
    if current_user.admin? || current_user?(@destination.user)
      @destination.destroy
      flash[:success] = "Destination deleted!"
      # admin ユーザーはホーム画面, current ユーザーはユーザー詳細画面へリダイレクト
      redirect_to request.referrer == user_url(@destination.user) ? user_url(@destination.user) : root_url
    else
      flash[:danger] = "You can't delete other user's destination."
      redirect_to root_url
    end
  end

  private

  def destination_params
    params.require(:destination).permit(:name, :description, :address, :latitude, :longitude, :country, :picture)
  end

  def correct_user
    # 現在のユーザーが更新対象の行き先を保有しているか確認
    @destination = current_user.destinations.find_by(id: params[:id])
    redirect_to root_url if @destination.nil?
  end
end
