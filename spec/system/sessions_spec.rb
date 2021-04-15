require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  let!(:user) { create(:user) }

  before do
    visit login_path
  end

  describe "Login ページ" do
    context "ページレイアウト" do
      it "Login の文字列の存在を確認" do
        expect(page).to have_content "Login"
      end

      it "ヘッダーメニューが正しく表示される " do
        expect(page).not_to have_link "ログイン", href: login_path
        expect(page).to have_link "サインアップ", href: signup_path
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
        expect(page).to have_link "ホーム", href: root_path
        expect(page).to have_link "Departureとは?", href: about_path
        expect(page).to have_link "サインアップ", href: signup_path
        expect(page).not_to have_link "ログイン", href: login_path
        expect(page).not_to have_link "ログアウト", href: logout_path

        fill_in "user_email", with: user.email
        fill_in "user_password", with: user.password
        click_button "ログイン"

        expect(page).to have_link "ホーム", href: root_path
        expect(page).to have_link "Departureとは?", href: about_path
        expect(page).to have_link "お気に入り", href: favorites_path
        expect(page).to have_link "シェアする", href:new_destination_path
        expect(page).to have_content "マイページ"
        expect(page).not_to have_link "プロフィール", href: user_path(user)
        expect(page).to have_link "受信トレイ", href: notifications_path
        expect(page).to have_link "ログアウト", href: logout_path
        expect(page).not_to have_link "ログイン", href: login_path
      end
    end
  end
end
