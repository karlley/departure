require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "static_pages#home" do
    context "ログインしていない場合" do
      before do
        visit root_path
      end

      it "Departure の文字列のが表示される" do
        expect(page).to have_content "Departure"
      end

      it "正しいタイトルが表示される" do
        expect(page).to have_title full_title
      end
    end

    context "ログイン済みの場合" do
      let(:user) { create(:user) }
      let(:destination) { create(:destination, :picture, user: user) }

      before do
        login_for_system(user)
        visit root_path
      end

      it "ヒーローイメージが表示される" do
        expect(page).to have_css ".hero-image"
        expect(page).to have_content "Departure"
        expect(page).to have_content "自分を探す旅に出よう"
      end

      it "キーワード検索エリアが表示される" do
        expect(page).to have_css ".static-page-home-keyword-wrapper"
        expect(page).to have_content "キーワードで探す"
        expect(page).to have_css ".static-page-home-search-form"
      end

      it "カテゴリー検索エリアが表示される" do
        expect(page).to have_css ".static-page-home-category-wrapper"
        expect(page).to have_content "エリアで探す"
        expect(page).to have_content "体験で探す"
        expect(page).to have_content "航空会社で探す"
      end

      context "カテゴリ検索での表示結果を動作確認" do
        context "エリア検索のリンクをクリックした場合" do
          let(:user) { create(:user) }
          let!(:destination_region_asia) { create(:destination, :region_asia, user: user) }
          let!(:destination_region_america) { create(:destination, :region_america, user: user) }
          let!(:destination_region_europe) { create(:destination, :region_europe, user: user) }

          before do
            login_for_system(user)
            visit root_path
          end

          it "アジアの絞り込み結果が表示される" do
            asia_link = find ".static-page-home-category-link.region-asia"
            asia_link.click
            expect(page).to have_css "h1", text: "\"アジア\" Search Results : 1"
            expect(page).to have_link destination_region_asia.name.truncate(30), href: destination_path(destination_region_asia)
            expect(page).to have_link destination_region_asia.user.name, href: user_path(destination_region_asia.user)
          end

          it "アメリカの絞り込み結果が表示される" do
            america_link = find ".static-page-home-category-link.region-america"
            america_link.click
            expect(page).to have_css "h1", text: "\"アメリカ\" Search Results : 1"
            expect(page).to have_link destination_region_america.name.truncate(30), href: destination_path(destination_region_america)
            expect(page).to have_link destination_region_america.user.name, href: user_path(destination_region_america.user)
          end

          it "ヨーロッパの絞り込み結果が表示される" do
            europe_link = find ".static-page-home-category-link.region-europe"
            europe_link.click
            expect(page).to have_css "h1", text: "\"ヨーロッパ\" Search Results : 1"
            expect(page).to have_link destination_region_europe.name.truncate(30), href: destination_path(destination_region_europe)
            expect(page).to have_link destination_region_europe.user.name, href: user_path(destination_region_europe.user)
          end
        end

        context "体験検索のリンクをクリックした場合" do
          let(:user) { create(:user) }
          let!(:destination_experience_activity) { create(:destination, :experience_activity, user: user) }
          let!(:destination_experience_history) { create(:destination, :experience_history, user: user) }
          let!(:destination_experience_solo_travel) { create(:destination, :experience_solo_travel, user: user) }

          before do
            login_for_system(user)
            visit root_path
          end

          it "アクティビティの絞り込み結果が表示される" do
            activity_link = find ".static-page-home-category-link.experience-activity"
            activity_link.click
            expect(page).to have_css "h1", text: "\"アクティビティ\" Search Results : 1"
            expect(page).to have_link destination_experience_activity.name.truncate(30), href: destination_path(destination_experience_activity)
            expect(page).to have_link destination_experience_activity.user.name, href: user_path(destination_experience_activity.user)
          end

          it "歴史の絞り込み結果が表示される" do
            history_link = find ".static-page-home-category-link.experience-history"
            history_link.click
            expect(page).to have_css "h1", text: "\"歴史\" Search Results : 1"
            expect(page).to have_link destination_experience_history.name.truncate(30), href: destination_path(destination_experience_history)
            expect(page).to have_link destination_experience_history.user.name, href: user_path(destination_experience_history.user)
          end

          it "一人旅の絞り込み結果が表示される" do
            solo_travel_link = find ".static-page-home-category-link.experience-solo-travel"
            solo_travel_link.click
            expect(page).to have_css "h1", text: "\"一人旅\" Search Results : 1"
            expect(page).to have_link destination_experience_solo_travel.name.truncate(30), href: destination_path(destination_experience_solo_travel)
            expect(page).to have_link destination_experience_solo_travel.user.name, href: user_path(destination_experience_solo_travel.user)
          end
        end

        context "航空会社検索のリンクをクリックした場合" do
          let(:user) { create(:user) }
          let!(:destination_alliance_star_alliance) { create(:destination, :alliance_star_alliance, user: user) }
          let!(:destination_alliance_one_world) { create(:destination, :alliance_one_world, user: user) }
          let!(:destination_alliance_sky_team) { create(:destination, :alliance_sky_team, user: user) }

          before do
            login_for_system(user)
            visit root_path
          end

          it "スターアライアンスの絞り込み結果が表示される" do
            europe_link = find ".static-page-home-category-link.alliance-star-alliance"
            europe_link.click
            expect(page).to have_css "h1", text: "\"スターアライアンス\" Search Results : 1"
            expect(page).to have_link destination_alliance_star_alliance.name.truncate(30), href: destination_path(destination_alliance_star_alliance)
            expect(page).to have_link destination_alliance_star_alliance.user.name, href: user_path(destination_alliance_star_alliance.user)
          end

          it "ワンワールドの絞り込み結果が表示される" do
            europe_link = find ".static-page-home-category-link.alliance-one-world"
            europe_link.click
            expect(page).to have_css "h1", text: "\"ワンワールド\" Search Results : 1"
            expect(page).to have_link destination_alliance_one_world.name.truncate(30), href: destination_path(destination_alliance_one_world)
            expect(page).to have_link destination_alliance_one_world.user.name, href: user_path(destination_alliance_one_world.user)
          end

          it "スカイチームの絞り込み結果が表示される" do
            europe_link = find ".static-page-home-category-link.alliance-sky-team"
            europe_link.click
            expect(page).to have_css "h1", text: "\"スカイチーム\" Search Results : 1"
            expect(page).to have_link destination_alliance_sky_team.name.truncate(30), href: destination_path(destination_alliance_sky_team)
            expect(page).to have_link destination_alliance_sky_team.user.name, href: user_path(destination_alliance_sky_team.user)
          end
        end
      end
    end
  end

  describe "static_pages#about" do
    before do
      visit about_path
    end

    it "What's Departure? の文字列の存在を確認" do
      expect(page).to have_content "What's Departure?"
    end

    it "正しいタイトル表示を確認" do
      expect(page).to have_title full_title("About")
    end
  end
end
