class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    # users/_list_follow から送信されたrelationship_user.id を:follow_idとしてフォローするユーザを取得
    @follow_user = User.find(params[:followed_id])
    current_user.follow(@follow_user)
    # user/_list_follow から送信されたcurrent_page_user.id で表示するユーザを取得
    @user = User.find(params[:current_page_user_id])
    respond_to do |format|
      # show/show-follow で分岐させる必要有り
      format.html { redirect_to @follow_user }
      format.js
    end
  end

  def destroy
    # users/_list_unfollow から送信されたrelationship_user.id を:follow_idとしてフォロー済みデータからアンフォローするユーザを取得
    @unfollow_user = Relationship.find(params[:id]).followed
    current_user.unfollow(@unfollow_user)
    # user/_list_follow から送信されたcurrent_page_user.id で表示するユーザを取得
    @user = User.find(params[:current_page_user_id])
    respond_to do |format|
      # show/show-follow で分岐させる必要有り
      format.html { redirect_to @unfollow_user }
      format.js
    end
  end

  # def create
  #   @user = User.find(params[:followed_id])
  #   current_user.follow(@user)
  #   respond_to do |format|
  #     # show/show-follow で分岐させる必要有り
  #     format.html { redirect_to @user }
  #     format.js
  #   end
  # end

  # def destroy
  #   @user = Relationship.find(params[:id]).followed
  #   current_user.unfollow(@user)
  #   respond_to do |format|
  #     # show/show-follow で分岐させる必要有り
  #     format.html { redirect_to @user }
  #     format.js
  #   end
  # end

end
