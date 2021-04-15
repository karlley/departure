require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "Home ページ" do
    context "ページレイアウト" do
      context "非ログイン時" do
        before do
          visit root_path
        end

        it "Departure の文字列の存在を確認" do
          expect(page).to have_content "Departure"
        end

        it "正しいタイトル表示を確認" do
          expect(page).to have_title full_title
        end
      end

      context "ログイン時" do
        let!(:user) { create(:user) }
        let!(:destination) { create(:destination, :picture, user: user) }

        before do
          login_for_system(user)
          visit root_path
        end

        it "All Destination の文字列を確認" do
          expect(page).to have_content "All Destination (#{user.destinations.count})"
        end

        it "'New Destination' ボタンの表示を確認" do
          expect(page).to have_link "New Destination", href: new_destination_path
        end

        it "行き先の情報が正しく表示されている事を確認" do
          expect(page).to have_selector "img[src$='test_destination_1.jpg']"
          expect(page).to have_link nil, href: destination_path(destination), class: "destination-picture-link"
          expect(page).to have_css "img.gravatar"
          expect(page).to have_link nil, href: user_path(user), class: "user-icon-link"
          expect(page).to have_link destination.name, href: destination_path(destination)
          expect(page).to have_link destination.user.name, href: user_path(user)
          # 国名を取得
          country_name = get_country_name(destination)
          expect(page).to have_content country_name
          expect(page).to have_css ".fa-heart"
          expect(page).to have_content "いいね!"
          expect(page).to have_css "span.timestamp"
        end

        it "行き先のページネーションの表示を確認" do
          # 行き先を13件作成
          create_list(:destination, 13, user: user)
          visit root_path
          expect(page).to have_css "div.pagination"
          # FIXME: Destination でのインスタンスの呼び出し方を修正
          Destination.take(12).each do |destination|
            expect(page).to have_link destination.name
          end
        end
      end
    end
  end

  describe "About ページ" do
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
