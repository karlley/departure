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
  end
end
