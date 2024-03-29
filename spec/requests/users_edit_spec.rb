require 'rails_helper'

RSpec.describe "プロフィール編集", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  context "認可されたユーザーの場合" do
    it "レスポンスが正常に表示される(+フレンドリーフォワーディング)" do
      get edit_user_path(user)
      login_for_request(user)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to edit_user_url(user)
      patch user_path(user), params: { user: {
        name: "Example User",
        email: "user@example.com",
        introduction: "My introduction",
        nationality: "USA",
      } }
      redirect_to user
      follow_redirect!
      expect(response).to render_template('users/show')
    end
  end

  context "ログインしていないユーザーの場合" do
    it "ログイン画面にリダイレクトする" do
      # edit
      get edit_user_path(user)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
      # update
      patch user_path(user), params: { user: {
        name: user.name,
        email: user.email,
      } }
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end

  context "別アカウントのユーザーの場合" do
    it "ホーム画面にリダイレクトする" do
      # edit
      login_for_request(other_user)
      get edit_user_path(user)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
      # update
      patch user_path(user), params: { user: {
        name: user.name,
        email: user.email,
      } }
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
    end
  end
end
