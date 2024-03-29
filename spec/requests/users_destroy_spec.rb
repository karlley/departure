require "rails_helper"

RSpec.describe "ユーザー削除", type: :request do
  let!(:admin_user) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  context "管理者ユーザーの場合" do
    it "ユーザーを削除後、ユーザー一覧ページにリダイレクトする" do
      login_for_request(admin_user)
      expect { delete user_path(user) }.to change(User, :count).by(-1)
      redirect_to users_url
      follow_redirect!
      expect(response).to render_template('users/index')
    end
  end

  context "管理者以外のユーザーの場合" do
    it "自分のアカウントを削除できる" do
      login_for_request(user)
      expect { delete user_path(user) }.to change(User, :count).by(-1)
      redirect_to root_url
    end

    it "自分以外のアカウントを削除が禁止されており、トップページへリダイレクトする" do
      login_for_request(user)
      expect { delete user_path(other_user) }.not_to change(User, :count)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
    end
  end

  context "ログインしていないユーザーの場合" do
    it "ログインページへリダイレクトする" do
      expect { delete user_path(user) }.not_to change(User, :count)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end

  context "投稿が関連するユーザーを削除した場合" do
    it "ユーザーと同時に関連の投稿も削除される" do
      login_for_request(user)
      expect { delete user_path(user) }.to change(Destination, :count).by(-1)
    end
  end
end
