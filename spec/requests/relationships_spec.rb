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

    it "create は実行不可, Login ページへリダイレクトすること" do
      expect do
        post relationships_path
      end.not_to change(Relationship, :count)
      expect(response).to redirect_to login_path
    end

    it "destroy は実行不可, Login ページへリダイレクトすること" do
      expect do
        delete relationship_path(user)
      end.not_to change(Relationship, :count)
      expect(response).to redirect_to login_path
    end
  end
end
