require 'rails_helper'

RSpec.describe "永続セッション機能", type: :request do
  let(:user) { create(:user) }

  context "'ログインしたままにする' にチェックをいれてログインする" do
    before do
      login_remember(user)
    end

    it "remember_token が空でないことを確認" do
      expect(response.cookies['remember_token']).not_to eq nil
    end

    it "セッションがnil のときでもcurrent_user が正しいユーザーを指すことを確認" do
      expect(current_user).to eq user
      expect(is_logged_in?).to be_truthy
    end
  end

  context "'ログインしたままにする' にチェックをいれずにログインする" do
    it "remember_token が空であることを確認" do
      # cookies を保存してログイン
      login_remember(user)
      delete logout_path
      # cookies を保存せずにログイン
      post login_path, params: { session: {
        email: user.email,
        password: user.password,
        remember_me: '0',
      } }
      expect(response.cookies['remember_token']).to eq nil
    end
  end

  context "ログアウトする" do
    it "ログイン中のみログアウトすることを確認" do
      login_for_request(user)
      expect(response).to redirect_to user_path(user)
      # ログアウト
      delete logout_path
      expect(response).to redirect_to root_path
      expect(session[:user_id]).to eq nil
      # 2番目のウィンドウでログアウト
      delete logout_path
      expect(response).to redirect_to root_path
      expect(session[:user_id]).to eq nil
    end
  end
end
