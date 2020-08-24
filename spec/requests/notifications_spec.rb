require 'rails_helper'

RSpec.describe "通知機能", type: :request do
  let!(:user) { create(:user) }

  describe "Notificatinos ページの表示" do
    context "ログイン済みユーザーの場合" do
      it "レスポンスが正常に表示されること" do
        login_for_request(user)
        get notifications_path
        expect(response).to render_template("notifications/index")
      end
    end

    context "未ログインのユーザーの場合" do
      it "Login ページへリダイレクトすること" do
        get notifications_path
        expect(response).to have_http_status "302"
        expect(response).to redirect_to login_path
      end
    end
  end
end
