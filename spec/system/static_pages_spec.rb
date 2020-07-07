require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "Home ページ" do
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

      context "行き先フィード", js: true do
        let!(:user) { create(:user) }
        let!(:destination) { create(:destination, user: user) }

        it "行き先のページネーションの表示を確認" do
          login_for_system(user)
          create_list(:destination, 6, user: user)
          visit root_path
          expect(page).to have_content "All Destination (#{user.destination.count})"
          expect(page).to have_css "div.pagination"
          Destination.take(5).each do |d|
            expect(page).to have_link d.name
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
