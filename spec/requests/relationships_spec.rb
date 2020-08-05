require 'rails_helper'

RSpec.describe "ユーザーフォロー機能", type: :request do
  let(:user) { create(:user) }

  context "ログインしていない場合" do
    it "Following ページからLogin ページへリダイレクトすること" do
      get following_user_path(user)
      expect(response).to redirect_to login_path
    end

    it "Followers ページからLogin ページへリダイレクトすること" do
      get followers_user_path(user)
      expect(response).to redirect_to login_path
    end
  end
end
