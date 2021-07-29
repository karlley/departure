class DestinationsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update]
  # 検索ワード無しでキーワード検索, マーカー取得をスキップ
  # skip_before_action :search_result, only: :index, unless: :have_search_word?
  # skip_before_action :search_result_markers, only: :index, unless: :have_search_word?
  # index アクション後にマーカー取得を実行
  # after_action :search_result_markers, only: :index

  def index
    # application_controller#search_result を表示
    if !params[:region].nil?
      region = params[:region]
      destinations = Destination.where('region LIKE?', "%#{region}%")
    elsif !params[:experience].nil?
      experience = params[:experience]
      destinations = Destination.where('experience LIKE?', "%#{experience}%")
    elsif !params[:alliance].nil?
      alliance = params[:alliance]
      destinations = Destination.where('alliance LIKE?', "%#{alliance}%")
    end
    @destinations = destinations.paginate(page: params[:page])

    @markers = Gmaps4rails.build_markers(@destinations) do |destination, marker|
      marker.lat(destination.latitude)
      marker.lng(destination.longitude)
      marker.infowindow render_to_string(partial: "destinations/map_infowindow", locals: { destination: destination })
    end
  end

  def show
    @destination = Destination.find(params[:id])
    @comment = Comment.new
    @comments = @destination.feed_comment(@destination.id)
    # GoogleMap 表示用のマーカーを作成
    @marker = Gmaps4rails.build_markers(@destination) do |destination, marker|
      marker.lat(destination.latitude)
      marker.lng(destination.longitude)
      marker.infowindow render_to_string(partial: "destinations/map_infowindow", locals: { destination: destination })
    end
    @country = Country.find_by(id: @destination.country_id)
    @airline = Airline.find_by(id: @destination.airline)
  end

  def new
    @destination = Destination.new
    # TODO: インスタンス変数化
    # @country = Country.all
    # @airline = Airline.all
  end

  def create
    # TODO: enum のAugumentError 対策
    @destination = current_user.destinations.build(destination_params)
    if @destination.save
      @destination.add_address
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
      @destination.update_address
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
    # params.require(:destination).permit(:name, :description, :spot, :latitude, :longitude, :address, :country, :picture, :expense, :season, :experience, :airline, :food)
    # :expense をenum 定義しているのでInt 型に変換して追加
    params.require(:destination).permit(:name, :description, :spot, :latitude, :longitude, :address, :country_id, :picture, :season, :experience, :airline, :food).merge(expense: params[:destination][:expense].to_i)
  end

  def correct_user
    # 現在のユーザーが更新対象の行き先を保有しているか確認
    @destination = current_user.destinations.find_by(id: params[:id])
    redirect_to root_url if @destination.nil?
  end
end
