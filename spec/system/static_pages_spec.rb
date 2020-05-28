require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "Home" do
    context "ページ全体" do
      before do
        visit root_path
      end

      it "Departure の文字列の存在を確認" do
        expect(page).to have_content "Departure"
      end

      it "正しいタイトルが表示されている事を確認" do
        expect(page).to have_title full_title
      end
    end
  end

  describe "About" do
    before do
      visit about_path
    end

    it "What's Departure?の文字列の存在を確認" do
      expect(page).to have_content "What's Departure?"
    end

    it "正しいタイトルが表示されている事を確認" do
      expect(page).to have_title full_title("About")
    end
  end
end
