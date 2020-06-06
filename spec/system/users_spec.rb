require 'rails_helper'

RSpec.describe "Users", type: :system do
  let!(:user) { create(:user) }

  describe "Signup ページ" do
    before do
      visit signup_path
    end

    context "ページレイアウト" do
      it "Signup の文字列の存在を確認" do
        expect(page).to have_content 'Signup'
      end

      it "正しいタイトル表示を確認" do
        expect(page).to have_title full_title('Signup')
      end
    end

    context "ユーザー登録処理" do
      it "有効なユーザーで登録処理を行うと成功のフラッシュが表示される事" do
        fill_in "ユーザー名", with: "Example User"
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード(確認)", with: "password"
        click_button "登録する"
        expect(page).to have_content "Welcome to Departure!"
      end

      it "無効なユーザーで登録処理を行うと失敗のフラッシュが表示される事" do
        fill_in "ユーザー名", with: ""
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード(確認)", with: "pass"
        click_button "登録する"
        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "パスワード(確認)とパスワードの入力が一致しません"
      end
    end
  end

  describe "Plofile ページ" do
    context "ページレイアウト" do
      before do
        visit user_path(user)
      end

      it "Profile の文字列の存在を確認" do
        expect(page).to have_content 'Profile'
      end

      it "正しいタイトル表示を確認" do
        expect(page).to have_title full_title('Profile')
      end

      it "ユーザー情報の表示を確認" do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
    end
  end
end
