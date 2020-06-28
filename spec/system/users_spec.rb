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
      it "有効なユーザーで登録処理を行うと成功のフラッシュが表示される" do
        fill_in "ユーザー名", with: "Example User"
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード(確認)", with: "password"
        click_button "サインアップ"
        expect(page).to have_content "Welcome to Departure!"
      end

      it "無効なユーザーで登録処理を行うと失敗のフラッシュが表示される" do
        fill_in "ユーザー名", with: ""
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード(確認)", with: "pass"
        click_button "サインアップ"
        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "パスワード(確認)とパスワードの入力が一致しません"
      end
    end
  end

  describe "Edit Profile ページ" do
    before do
      login_for_system(user)
      visit user_path(user)
      click_link "Edit Profile"
    end

    context "ページレイアウト" do
      it "正しいタイトルが表示されることを確認" do
        expect(page).to have_title full_title('Edit Profile')
      end

      it "有効なプロフィール更新で成功のフラッシュが表示されること" do
        fill_in "ユーザー名", with: "Edit Example User"
        fill_in "メールアドレス", with: "edit-user@example.com"
        fill_in "自己紹介", with: "My Introduction!"
        fill_in "国籍", with: "Japan"
        click_button "更新する"
        expect(page).to have_content "Your Profile has been updated!"
        expect(user.reload.name).to eq "Edit Example User"
        expect(user.reload.email).to eq "edit-user@example.com"
        expect(user.reload.introduction).to eq "My Introduction!"
        expect(user.reload.nationality).to eq "Japan"
      end

      it "無効なプロフィール更新で適切なエラーメッセージが表示されること" do
        fill_in "ユーザー名", with: ""
        fill_in "メールアドレス", with: ""
        click_button "更新する"
        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "メールアドレスを入力してください"
        expect(page).to have_content "メールアドレスは不正な値です"
        expect(user.reload.email).not_to eq ""
      end
    end
  end

  describe "Profile ページ" do
    context "ページレイアウト" do
      before do
        login_for_system(user)
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
        expect(page).to have_content user.nationality
      end

      it "Edit Profile ページヘのリンク表示を確認" do
        expect(page).to have_link "Edit Profile", href: edit_user_path(user)
      end
    end
  end
end
