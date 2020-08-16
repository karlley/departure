require 'rails_helper'

RSpec.describe "コメント機能", type: :request do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination) }
  let!(:comment) { create(:comment, user_id: user.id, destination: destination) }

  describe "コメントの登録" do
    context "ログイン済みの場合" do
    end

    context "未ログインの場合" do
      it "コメント登録不可, Login ページへリダイレクトすること" do
        expect do
          post comments_path, params: {
            destination_id: destination.id,
            comment: { content: "This is a comment!" },
          }
        end.not_to change(destination.comments, :count)
        expect(response).to redirect_to login_path
      end
    end
  end

  describe "コメントの削除" do
    context "ログイン済みの場合" do
    end

    context "未ログインの場合" do
      it "コメント削除不可, Login ページへリダイレクトすること" do
        expect do
          delete comment_path(comment)
        end.not_to change(destination.comments, :count)
      end
    end
  end
end
