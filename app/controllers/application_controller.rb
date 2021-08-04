class ApplicationController < ActionController::Base
  # logged_in? を使えるようにする
  include SessionsHelper
  # search_query? を使えるようにする
  include ApplicationHelper
  # ヘッダーの検索バーからの検索用
  before_action :search_result, if: proc { search_query? && logged_in? }
  # 検索結果以外のページ表示用
  before_action :no_search_query, if: proc { !search_query? && logged_in? }
  # CSRF対策
  protect_from_forgery with: :exception

  # TODO: 条件検索も追加
  # 検索ワード有りで検索結果/検索ワード無しで全投稿取得
  def search_result
    search_word = params[:q][:name_or_spot_or_address_cont]
    # 検索ワードからスペース区切りで配列を作成
    # 検索ワードの数だけ検索ワードをkey にしたハッシュを作成
    grouping_hash = search_word.split(/[\p{blank}\s]+/).reduce({}) { |hash, word| hash.merge(word => { name_or_spot_or_address_cont: word }) }
    # h1 表示用
    @search_word = search_word
    # 検索クエリ
    @q = Destination.paginate(page: params[:page], per_page: 12).ransack({ combinator: 'or', groupings: grouping_hash })
    # 検索結果(distinct: true で重複除外)
    @destinations = @q.result(distinct: true)
    # 検索結果からGoogleMap 表示用マーカー
    @markers = Gmaps4rails.build_markers(@destinations) do |destination, marker|
      marker.lat(destination.latitude)
      marker.lng(destination.longitude)
      marker.infowindow render_to_string(partial: "destinations/map_infowindow", locals: { destination: destination })
    end
  end

  # search_form_for 用にransack オブジェクト を返す
  def no_search_query
    # params[:q] はnil
    @q = Destination.ransack(params[:q])
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
