require 'rails_helper'

RSpec.describe "かんたんログイン機能", type: :request do
  let(:guest_user) { create(:user, :guest) }

  it "ゲストユーザーでログイン/ログアウトできる" do
    post guest_login_path, params: { session: {
      email: "guest@example.com",
    } }
    follow_redirect!
    expect(response).to render_template("static_pages/home")
    expect(is_logged_in?).to be_truthy
    delete logout_path
    expect(is_logged_in?).not_to be_truthy
    follow_redirect!
    expect(response).to render_template("static_pages/home")
  end

  it "ゲストユーザーが削除されている場合でもゲストユーザーでログインできる" do
    # ゲストユーザー呼出し
    guest_user
    get root_path
    post guest_login_path, params: { session: {
      email: "guest@example.com",
    } }
    expect(is_logged_in?).to be_truthy
    # ゲストユーザー削除
    delete user_path(guest_user)
    post guest_login_path, params: { session: {
      email: "guest@example.com",
    } }
    expect(is_logged_in?).to be_truthy
  end
end
