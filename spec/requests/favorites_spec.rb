require 'rails_helper'

RSpec.describe "お気に入り機能", type: :request do
  let(:user) { create(:user) }
  let(:destination) { create(:destination) }

  describe "お気に入り登録処理" do
    context "ログインしていない場合" do
      it "お気に入り登録不可, Login ページへリダイレクトすること" do
        expect do
          post "/favorites/#{destination.id}/create"
        end.not_to change(Favorite, :count)
        expect(response).to redirect_to login_path
      end

      it "お気に入り解除不可, Login ページへリダイレクトすること" do
        expect do
          delete "/favorites/#{destination.id}/destroy"
        end.not_to change(Favorite, :count)
        expect(response).to redirect_to login_path
      end
    end

    context "ログイン済みの場合" do
      before do
        login_for_request(user)
      end

      it "お気に入り登録ができること" do
        expect do
          post "/favorites/#{destination.id}/create"
        end.to change(user.favorites, :count).by(1)
      end

      it "Ajax を使用したお気に入り登録ができること" do
        expect do
          post "/favorites/#{destination.id}/create", xhr: true
        end.to change(user.favorites, :count).by(1)
      end

      it "お気に入り解除ができること" do
        user.favorite(destination)
        expect do
          delete "/favorites/#{destination.id}/destroy"
        end.to change(user.favorites, :count).by(-1)
      end

      it "Ajax を使用したお気に入り解除ができること" do
        user.favorite(destination)
        expect do
          delete "/favorites/#{destination.id}/destroy", xhr: true
        end.to change(user.favorites, :count).by(-1)
      end
    end
  end
end
