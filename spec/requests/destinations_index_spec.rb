require 'rails_helper'

RSpec.describe "Destinations Search ページ", type: :request do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  context "ログイン済みのユーザーの場合" do
    it "レスポンスが正常に表示されること" do
      login_for_request(user)
      get destinations_path
      expect(response).to have_http_status "200"
      expect(response).to render_template("destinations/index")
    end
  end

  context "未ログインのユーザーの場合" do
    it "ログイン画面にリダイレクトすること" do
      get destinations_path
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end
end
