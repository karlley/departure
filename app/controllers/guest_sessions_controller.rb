class GuestSessionsController < ApplicationController
  # login メソッドを使えるようにする
  include SessionsHelper

  def create
    user = User.find_or_create_by(email: "guest@example.com") do |u|
      u.password = SecureRandom.urlsafe_base64
      u.name = "ゲストユーザー"
      u.introduction = "ゲストユーザーです！\n機能を試してみてください！"
      u.nationality = "日本"
    end
    log_in user
    remember user
    flash[:success] = "ゲストユーザーでログインしました"
    redirect_to root_url
  end
end
