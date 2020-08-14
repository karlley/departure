require 'rails_helper'

RSpec.describe "Users", type: :system do
  let!(:user) { create(:user) }
  let!(:admin_user) { create(:user, :admin) }
  let!(:other_user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }
  let!(:other_destination) { create(:destination, user: other_user) }

  describe "All Users ページ" do
    context "管理者ユーザーの場合" do
      it "ページネーション機能, 自分以外のユーザーの削除ボタンが表示される" do
        create_list(:user, 30)
        login_for_system(admin_user)
        visit users_path
        expect(page).to have_css "div.pagination"
        User.paginate(page: 1).each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          expect(page).to have_content "#{u.name} | 削除" unless u == admin_user
        end
      end
    end

    context "管理者ユーザー以外の場合" do
      it "ページネーション, 自分のアカウントのみ削除ボタンが表示される" do
        create_list(:user, 30)
        login_for_system(user)
        visit users_path
        expect(page).to have_css "div.pagination"
        User.paginate(page: 1).each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          if u == user
            expect(page).to have_content "#{u.name} | 削除"
          else
            expect(page).not_to have_content "#{u.name} | 削除"
          end
        end
      end
    end
  end

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

    context "アカウント削除処理", js: true do
      it "正常に削除できる" do
        click_link "アカウントを削除する"
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content "Your Account has been deleted!"
      end
    end
  end

  describe "Profile ページ" do
    context "ページレイアウト" do
      before do
        login_for_system(user)
        create_list(:destination, 10, user: user)
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

      it "行き先の件数の表示を確認" do
        expect(page).to have_content "行き先 (#{user.destinations.count})"
      end

      it "行き先の情報の表示を確認" do
        Destination.take(5).each do |destination|
          expect(page).to have_link destination.name
          expect(page).to have_content destination.user.name
          expect(page).to have_content destination.description
          expect(page).to have_content destination.country
        end
      end

      it "行き先のページネーションの表示を確認" do
        expect(page).to have_css "div.pagination"
      end
    end
  end

  describe "フォロー機能" do
    context "ユーザーのフォロー/アンフォロー処理", js: true do
      it "ユーザーのフォロー/アンフォローができること" do
        login_for_system(user)
        visit user_path(other_user)
        expect(page).to have_button "Follow"
        click_button "Follow"
        expect(page).to have_button "Followed"
        click_button "Followed"
        expect(page).to have_button "Follow"
      end
    end
  end

  describe "お気に入り機能" do
    context "行き先のお気に入り登録/解除処理" do
      before do
        login_for_system(user)
      end

      it "favorite, unfavorite, favorite? メソッドが正常に動作すること" do
        expect(user.favorite?(destination)).to be_falsey
        user.favorite(destination)
        expect(user.favorite?(destination)).to be_truthy
        user.unfavorite(destination)
        expect(user.favorite?(destination)).to be_falsey
      end

      it "Home ページからお気に入り登録/解除ができること", js: true do
        visit root_path
        link = find('.favorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/create"
        link.click
        link = find('.unfavorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/destroy"
        link.click
        link = find('.favorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/create"
      end

      it "User show ページからお気に入り登録/解除ができること", js: true do
        visit user_path(user)
        link = find('.favorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/create"
        link.click
        link = find('.unfavorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/destroy"
        link.click
        link = find('.favorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/create"
      end

      it "Destination show ページからお気に入り登録/解除ができること", js: true do
        visit destination_path(destination)
        link = find('.favorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/create"
        link.click
        link = find('.unfavorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/destroy"
        link.click
        link = find('.favorite')
        expect(link[:href]).to include "/favorites/#{destination.id}/create"
      end
    end

    describe "Favorites ページ" do
      before do
        login_for_system(user)
      end

      context "ページレイアウト" do
        before do
          visit favorites_path
        end

        it "'Favorites' の文字列の存在を確認" do
          expect(page).to have_content "Favorites"
        end

        it "正しいタイトル表示を確認" do
          expect(page).to have_title full_title("Favorites")
        end
      end

      context "お気に入り 一覧表示" do
        it "お気に入りの行き先の情報が正しく表示されること" do
          user.favorite(destination)
          visit favorites_path
          expect(page).to have_content destination.name
          expect(page).to have_content destination.description
          expect(page).to have_content "country: #{destination.country}"
          expect(page).to have_content "posted by #{user.name}"
          expect(page).to have_link user.name, href: user_path(user)
        end

        it "お気に入りの数だけお気に入りの行き先が表示されること" do
          visit favorites_path
          expect(page).not_to have_css ".favorite-destination"
          user.favorite(destination)
          user.favorite(other_destination)
          visit favorites_path
          expect(page).to have_css ".favorite-destination", count: 2
          user.unfavorite(other_destination)
          visit favorites_path
          expect(page).to have_css ".favorite-destination", count: 1
        end
      end
    end
  end
end
