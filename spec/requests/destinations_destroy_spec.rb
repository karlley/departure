require "rails_helper"

RSpec.describe "行き先削除", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  context "ログイン済み、自分の行き先を削除する場合" do
    it "処理が成功し、トップページにリダイレクトすること" do
      login_for_request(user)
      expect { delete destination_path(destination) }.to change(Destination, :count).by(-1)
      redirect_to user_path(user)
      follow_redirect!
      expect(response).to render_template('static_pages/home')
    end
  end

  context "ログイン済み、他人の行き先を削除する場合" do
    it "処理が失敗し、トップページにリダイレクトすること" do
      login_for_request(other_user)
      expect { delete destination_path(destination) }.not_to change(Destination, :count)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
    end
  end

  context "未ログインの場合" do
    it "ログインページへリダイレクトすること" do
      expect { delete destination_path(destination) }.not_to change(Destination, :count)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end
end
