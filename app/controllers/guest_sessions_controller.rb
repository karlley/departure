class GuestSessionsController < ApplicationController
  # login メソッドを使えるようにする
  include SessionsHelper

  def create
    guest_user = User.find_or_create_by(email: "guest@example.com") do |g|
      g.password = SecureRandom.urlsafe_base64
      g.name = "ゲストユーザー"
      g.introduction = "ゲストユーザーです！\n機能を試してみてください！"
      g.nationality = "日本"
    end
    log_in guest_user
    remember guest_user
    flash[:success] = "#{guest_user.name} でログインしました"
    redirect_to root_url
  end
end
