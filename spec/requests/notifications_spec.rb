require 'rails_helper'

RSpec.describe "通知機能", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }
  let!(:other_destination) { create(:destination, user: other_user) }

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

  describe "通知処理" do
    before do
      login_for_request(user)
    end

    context "自分以外のユーザーの投稿に対して" do
      it "お気に入り登録で通知が作成されること" do
        post "/favorites/#{other_destination.id}/create"
        expect(user.reload.notification).to be_falsey
        expect(other_user.reload.notification).to be_truthy
      end

      it "コメント追加で通知が作成されること" do
        post comments_path, params: { destination_id: other_destination.id, comment: { content: "This is comment!" } }
        expect(user.reload.notification).to be_falsey
        expect(other_user.reload.notification).to be_truthy
      end
    end

    context "自分の投稿に対して" do
      it "お気に入り登録で通知が作成されないこと" do
        post "/favorites/#{destination.id}/create"
        expect(user.reload.notification).to be_falsey
      end

      it "コメント追加で通知が作成されないこと" do
        post comments_path, params: { destination_id: destination.id, comment: { content: "This is comment!" } }
        expect(user.reload.notification).to be_falsey
      end
    end
  end
end
