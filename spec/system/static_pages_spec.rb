require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "static_pages#home" do
    context "ページ全体" do
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

    context "行き先フィード", js: true do
      let!(:user) { create(:user) }
      let!(:destination) { create(:destination, user: user) }

      before do
        login_for_system(user)
      end

      it "行き先のページネーションの表示を確認" do
        create_list(:destination, 6, user: user)
        visit root_path
        expect(page).to have_content "All Destination (#{user.destinations.count})"
        expect(page).to have_css "div.pagination"
        Destination.take(5).each do |d|
          expect(page).to have_link d.name
        end
      end

      it "'New Destination' ボタンの表示を確認" do
        visit root_path
        expect(page).to have_link "New Destination", href: new_destination_path
      end

      it "行き先削除後、削除成功のフラッシュの表示を確認" do
        visit root_path
        click_on "delete"
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content "Destination deleted!"
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
