require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "static_pages#home" do
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

        it "ヒーローイメージの文字列を確認" do
          expect(page).to have_content "Departure"
        end

        it "行き先の情報が正しく表示されている事を確認" do
          # 写真
          expect(page).to have_css "img.gravatar"
          expect(page).to have_content destination.name
          expect(page).to have_content "いいね!"
          expect(page).to have_content destination.description
          country_name = get_country_name(destination)
          expect(page).to have_content country_name
          expect(page).to have_css "span.timestamp"
          expect(page).to have_link "delete", href: destination_path(destination)
        end
      end
    end

    # FIXME: destinations#index に移動する
    # context "行き先フィード" do
    #   let!(:user) { create(:user) }
    #   let!(:destination) { create(:destination, user: user) }

    #   before do
    #     login_for_system(user)
    #   end

    #   it "行き先のページネーションの表示を確認" do
    #     create_list(:destination, 6, user: user)
    #     visit root_path
    #     expect(page).to have_content "All Destination (#{user.destinations.count})"
    #     expect(page).to have_css "div.pagination"
    #     Destination.take(5).each do |d|
    #       expect(page).to have_link d.name
    #     end
    #   end

    #   it "行き先削除後、削除成功のフラッシュの表示を確認", js: true do
    #     visit root_path
    #     click_on "delete"
    #     page.driver.browser.switch_to.alert.accept
    #     expect(page).to have_content "Destination deleted!"
    #   end
    # end
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
