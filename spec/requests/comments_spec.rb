require 'rails_helper'

RSpec.describe "コメント機能", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:destination) { create(:destination) }
  let!(:comment) { create(:comment, user_id: user.id, destination: destination) }

  describe "コメントの登録" do
    context "ログイン済みの場合" do
      before do
        login_for_request(user)
      end

      it "有効な内容のコメントが登録できること" do
        expect do
          post comments_path, params: { destination_id: destination.id, comment: { content: "This is comment!" } }
        end.to change(destination.comments, :count).by(1)
      end

      it "無効な内容のコメントが登録できないこと" do
        expect do
          post comments_path, params: { destination_id: destination.id, comment: { content: "" } }
        end.not_to change(destination.comments, :count)
      end
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
      context "コメントを作成したユーザーである場合" do
        it "コメントの削除ができること" do
          login_for_request(user)
          expect do
            delete comment_path(comment)
          end.to change(destination.comments, :count).by(-1)
        end
      end

      context "コメントを作成したユーザーでない場合" do
        it "コメントの削除はできないこと" do
          login_for_request(other_user)
          expect do
            delete comment_path(comment)
          end.not_to change(destination.comments, :count)
        end
      end
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
