require 'rails_helper'

RSpec.describe "ユーザーフォロー機能", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  context "ログイン済みの場合" do
    before do
      login_for_request(user)
    end

    it "ユーザーのフォローができること" do
      expect do
        post relationships_path, params: { followed_id: other_user.id }
      end.to change(user.following, :count).by(1)
    end

    it "Ajax によるユーザーのフォローができること" do
      expect do
        post relationships_path, xhr: true, params: { followed_id: other_user.id }
      end.to change(user.following, :count).by(1)
    end

    it "ユーザーのアンフォローができること" do
      user.follow(other_user)
      relationship = user.active_relationships.find_by(followed_id: other_user.id)
      expect do
        delete relationship_path(relationship)
      end.to change(user.following, :count).by(-1)
    end

    it "Ajax によるユーザーのアンフォローができること" do
      user.follow(other_user)
      relationship = user.active_relationships.find_by(followed_id: other_user.id)
      expect do
        delete relationship_path(relationship), xhr: true
      end.to change(user.following, :count).by(-1)
    end
  end

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
