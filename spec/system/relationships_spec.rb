require 'rails_helper'

RSpec.describe "Relationships", type: :system do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:user4) { create(:user) }
  let!(:destination1) { create(:destination, user: user1) }
  let!(:destination2) { create(:destination, user: user2) }
  let!(:destination3) { create(:destination, user: user3) }

  describe "users#following" do
    before do
      create(:relationship, follower_id: user1.id, followed_id: user2.id)
      create(:relationship, follower_id: user1.id, followed_id: user3.id)
      login_for_system(user1)
      visit following_user_path(user1)
    end

    context "ページレイアウト" do
      it "'Following'の文字列が存在すること" do
        expect(page).to have_content "Following"
      end

      it "正しいタイトルが表示される事" do
        expect(page).to have_title full_title("Following")
      end

      it "ユーザー情報が表示されていること" do
        expect(page).to have_content user1.name
        expect(page).to have_link "Profile", href: user_path(user1)
        expect(page).to have_content "行き先 #{user1.destinations.count}"
        expect(page).to have_link "#{user1.following.count} following", href: following_user_path(user1)
        expect(page).to have_link "#{user1.followers.count} followers", href: followers_user_path(user1)
      end

      it "フォロー中のユーザーが表示されていること" do
        within('.users') do
          expect(page).to have_css 'li', count: user1.following.count
          user1.following.each do |u|
            expect(page).to have_link u.name, href: user_path(u)
          end
        end
      end
    end
  end

  describe "users#followers" do
    before do
      create(:relationship, follower_id: user2.id, followed_id: user1.id)
      create(:relationship, follower_id: user3.id, followed_id: user1.id)
      create(:relationship, follower_id: user4.id, followed_id: user1.id)
      login_for_system(user1)
      visit followers_user_path(user1)
    end

    context "ページレイアウト" do
      it "'Followers'の文字列が存在すること" do
        expect(page).to have_content "Followers"
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("Followers")
      end

      it "ユーザー情報が表示されていること" do
        expect(page).to have_content user1.name
        expect(page).to have_link "Profile", href: user_path(user1)
        expect(page).to have_content "行き先 #{user1.destinations.count}"
        expect(page).to have_link "#{user1.following.count} following", href: following_user_path(user1)
        expect(page).to have_link "#{user1.followers.count} followers", href: followers_user_path(user1)
      end

      it "フォロワーが表示されていること" do
        within('.users') do
          expect(page).to have_css 'li', count: user1.followers.count
          user1.followers.each do |u|
            expect(page).to have_link u.name, href: user_path(u)
          end
        end
      end
    end
  end

  describe "フィード" do
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
