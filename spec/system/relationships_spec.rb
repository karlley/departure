require 'rails_helper'

RSpec.describe "Relationships", type: :system do
  describe "users#following" do
    context "ログインユーザがフォロー中一覧ページにアクセスした場合" do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      before do
        # user1 がuser2 をフォロー > user1 のフォロー一覧
        create(:relationship, follower_id: user1.id, followed_id: user2.id)
        login_for_system(user1)
        visit following_user_path(user1)
      end

      it "'Following / Followers'が表示される" do
        expect(page).to have_content "Following / Followers"
      end

      it "users#followers へのリンクが表示される" do
        expect(page).to have_link "Followers", href: followers_user_path(user1)
      end

      it "正しいタイトルが表示される事" do
        expect(page).to have_title full_title("Following")
      end

      it "ユーザー名、フォロー数、フォロワー数が表示される" do
        expect(page).to have_content user1.name
        expect(page).to have_content "フォロワー #{user1.followers.count}人"
        expect(page).to have_content "フォロー #{user1.following.count}人"
      end

      it "フォロー中のユーザの表示件数が正しく表示される" do
        within('.user-follow-list-wrapper') do
          expect(page).to have_css 'li.user-follow-list-user', count: user1.following.count
        end
      end

      it "フォロー中のユーザ名、自己紹介が表示される" do
        user1.following.each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          expect(page).to have_content u.introduction
        end
      end

      it "フォローする/フォロー中のボタンがAjax で表示される", js: true do
        expect(page).to have_css "div.user-follow-relationship"
        expect(page).to have_css "input.unfollow-button"
        expect(page).to have_button "フォロー中"
        click_button "フォロー中"
        expect(page).to have_css "div.user-follow-relationship"
        expect(page).to have_css "input.follow-button"
        expect(page).to have_button "フォローする"
      end

      it "フォローする/フォロー中のボタンが自分のアカウントには表示されない" do
        # フォローしたuser2のフォロワー一覧でuser1のアカウントのボタン表示を確認
        visit followers_user_path(user2)
        expect(page).not_to have_css "div.user-follow-relationship"
      end
    end
  end

  describe "users#followers" do
    context "ログインユーザがフォロー中一覧ページにアクセスした場合" do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      before do
        # user2 がuser1 をフォロー > user1 のフォロワー一覧
        create(:relationship, follower_id: user2.id, followed_id: user1.id)
        login_for_system(user1)
        visit followers_user_path(user1)
      end

      it "'Following / Followers'が表示される" do
        expect(page).to have_content "Following / Followers"
      end

      it "users#following へのリンクが表示される" do
        expect(page).to have_link "Following", href: following_user_path(user1)
      end

      it "正しいタイトルが表示される事" do
        expect(page).to have_title full_title("Followers")
      end

      it "ユーザー名、フォロー数、フォロワー数が表示される" do
        expect(page).to have_content user1.name
        expect(page).to have_content "フォロワー #{user1.followers.count}人"
        expect(page).to have_content "フォロー #{user1.following.count}人"
      end

      it "フォロワーのユーザの表示件数が正しく表示される" do
        within('.user-follow-list-wrapper') do
          expect(page).to have_css 'li.user-follow-list-user', count: user1.followers.count
        end
      end

      it "フォロー中のユーザ名、自己紹介が表示される" do
        user1.followers.each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          expect(page).to have_content u.introduction
        end
      end

      it "フォローする/フォロー中のボタンがAjax で表示される", js: true do
        expect(page).to have_css "div.user-follow-relationship"
        expect(page).to have_css "input.follow-button"
        expect(page).to have_button "フォローする"
        click_button "フォローする"
        expect(page).to have_css "div.user-follow-relationship"
        expect(page).to have_css "input.unfollow-button"
        expect(page).to have_button "フォロー中"
      end

      it "フォローする/フォロー中のボタンが自分のアカウントには表示されない" do
        # user2 のフォロー一覧でuser1のアカウントのボタン表示を確認
        visit following_user_path(user2)
        expect(page).not_to have_css "div.user-follow-relationship"
      end
    end
  end

  describe "フィード" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }
    let(:destination1) { create(:destination, user: user1) }
    let(:destination2) { create(:destination, user: user2) }
    let(:destination3) { create(:destination, user: user3) }

    before do
      create(:relationship, follower_id: user1.id, followed_id: user2.id)
      login_for_system(user1)
    end

    it "フィードに自分の投稿が含まれていること" do
      expect(user1.feed).to include destination1
    end

    it "フィードにフォロー中のユーザーの投稿が含まれていること" do
      expect(user1.feed).to include destination2
    end

    it "フィートにフォローしていないユーザーの投稿が含まれていないこと" do
      expect(user1.feed).not_to include destination3
    end
  end
end
