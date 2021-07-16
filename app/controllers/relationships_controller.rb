class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    if params[:current_page_user_id].blank?
      # users/show
      # :followed_id からフォローするユーザを取得
      @follow_user = User.find(params[:followed_id])
      current_user.follow(@follow_user)
      respond_to do |format|
        format.html { redirect_to @follow_user }
        format.js
      end
    else
      # users/show_follow
      # :followed_id からフォローするユーザを取得
      @follow_user = User.find(params[:followed_id])
      current_user.follow(@follow_user)
      # user/_list_follow から送信されたcurrent_page_user.id で表示するユーザを取得
      @user = User.find(params[:current_page_user_id])
      respond_to do |format|
        format.html { redirect_to @user }
        format.js
      end
    end
  end

  def destroy
    if params[:current_page_user_id].blank?
      # users/show
      # フォロー済みデータからアンフォローするユーザを取得
      @unfollow_user = Relationship.find(params[:id]).followed
      current_user.unfollow(@unfollow_user)
      respond_to do |format|
        format.html { redirect_to @unfollow_user }
        format.js
      end
    else
      # users/show_follow
      # フォロー済みデータからアンフォローするユーザを取得
      @unfollow_user = Relationship.find(params[:id]).followed
      @unfollow_user = Relationship.find(params[:id]).followed
      current_user.unfollow(@unfollow_user)
      # user/_list_follow から送信されたcurrent_page_user.id で表示するユーザを取得
      @user = User.find(params[:current_page_user_id])
      respond_to do |format|
        format.html { redirect_to @user }
        format.js
      end
    end
  end
end
