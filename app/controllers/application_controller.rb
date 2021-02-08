class ApplicationController < ActionController::Base
  # 全てのアクションで@q, @destinations, @search_word がセットする
  before_action :set_search
  # CSRF対策
  protect_from_forgery with: :exception
  # logged_in? を使えるようにする
  include SessionsHelper
  # have_search_word? を使えるようにする
  include ApplicationHelper

  # フィードから検索条件に該当する行き先を検索
  def set_search
    if logged_in? && have_search_word?
      # 検索ワードからスペース区切りで配列を作成
      search_word = params[:q][:name_or_spot_or_address_cont].split(/[\p{blank}\s]+/)
      # 検索ワードの数だけ検索ワードをkey にしたハッシュを作成
      grouping_hash = search_word.reduce({}) { |hash, word| hash.merge(word => { name_or_spot_or_address_cont: word }) }
      # ユーザのフィードから検索
      @q = current_user.feed.paginate(page: params[:page], per_page: 5).ransack({ combinator: 'or', groupings: grouping_hash })
      # 検索結果(distinct: true で重複除外)
      @destinations = @q.result(distinct: true)
      # view タイトル表示ようにインスタンス変数化
      @search_word = search_word
    else
      # ransack メソッドを使って@q を取得しないとNo Ransack::Search エラーが出る
      @q = current_user.feed.paginate(page: params[:page], per_page: 5).ransack(params[:q])
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
