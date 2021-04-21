require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  let!(:user) { create(:user) }

  before do
    visit login_path
  end

  describe "sessions#new" do
    context "ページレイアウト" do
      it "Login の文字列の存在を確認" do
        expect(page).to have_content "Login"
      end

      it "正しいタイトル表示を確認" do
        expect(page).to have_title full_title("Login")
      end

      it "ログインフォームのラベルが正しく表示される" do
        expect(page).to have_content "メールアドレス"
        expect(page).to have_content "パスワード"
      end

      it "ログインフォームが正しく表示される" do
        expect(page).to have_css "input#user_email"
        expect(page).to have_css "input#user_password"
      end

      it "'ログインしたままにする' チェックボックスが表示される" do
        expect(page).to have_content "ログインしたままにする"
        expect(page).to have_css "input#session_remember_me"
      end

      it "ログインボタンが表示される" do
        expect(page).to have_button "ログイン"
      end

      it "ヘッダーにLogin ページのリンクを確認" do
        expect(page).to have_link "Login", href: login_path
      end
    end

    context "ログイン処理" do
      it "無効なユーザーでログイン失敗を確認" do
        fill_in "user_email", with: "user@example.com"
        fill_in "user_password", with: "pass"
        click_button "ログイン"
        expect(page).to have_content "メールアドレスとパスワードの組み合わせが誤っています"

        visit root_path
        expect(page).not_to have_content "メールアドレスとパスワードの組み合わせが誤っています"
      end

      it "有効なユーザーでログイン時に正しいヘッダーの表示を確認" do
        expect(page).to have_link "What's Departure?", href: about_path
        expect(page).to have_link "Signup", href: signup_path
        expect(page).to have_link "Login", href: login_path
        expect(page).not_to have_link "Logout", href: logout_path

        fill_in "user_email", with: user.email
        fill_in "user_password", with: user.password
        click_button "ログイン"

        expect(page).to have_link "What's Departure?", href: about_path
        expect(page).to have_link "All Users", href: users_path
        expect(page).to have_content "My Page"
        expect(page).to have_link "Logout", href: logout_path
        expect(page).not_to have_link "Login", href: login_path
      end
    end
  end
end
