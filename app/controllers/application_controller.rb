class ApplicationController < ActionController::Base
  # 全てのアクションで下記メソッドを実行
  before_action :set_search
  before_action :set_markers
  # CSRF対策
  protect_from_forgery with: :exception
  # logged_in? を使えるようにする
  include SessionsHelper
  # have_search_word? を使えるようにする
  include ApplicationHelper

  # TODO: 条件検索も追加
  # フィード から検索条件に該当する行き先を検索
  def set_search
    if logged_in?
      if have_search_word?
        search_word = params[:q][:name_or_spot_or_address_cont]
        # 検索ワードからスペース区切りで配列を作成
        # 検索ワードの数だけ検索ワードをkey にしたハッシュを作成
        grouping_hash = search_word.split(/[\p{blank}\s]+/).reduce({}) { |hash, word| hash.merge(word => { name_or_spot_or_address_cont: word }) }
        # view h1 表示用にインスタンス変数化
        @search_word = search_word
      else
        grouping_hash = nil
      end
      # ユーザのフィードから検索ワード検索/全件取得
      @q = current_user.feed.paginate(page: params[:page], per_page: 12).ransack({ combinator: 'or', groupings: grouping_hash })
      # 検索結果(distinct: true で重複除外)
      @destinations = @q.result(distinct: true)
    end
  end

  # 検索結果からGoogleMap 表示用のマーカーを作成
  def set_markers
    @markers = Gmaps4rails.build_markers(@destinations) do |destination, marker|
      marker.lat(destination.latitude)
      marker.lng(destination.longitude)
      marker.infowindow render_to_string(partial: "destinations/map_infowindow", locals: { destination: destination })
    end
  end

  private

  # ログイン済みユーザーか確認
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください"
      redirect_to login_url
    end
  end
end
