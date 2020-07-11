require 'rails_helper'

RSpec.describe "Destinations", type: :system do
  let!(:user) { create(:user) }

  describe "New Destination ページ" do
    before do
      login_for_system(user)
      visit new_destination_path
    end

    context "ページレイアウト" do
      it "'New Destination' の文字列が存在すること" do
        expect(page).to have_content 'New Destination'
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('New Destination')
      end

      it "入力フォームに正しいラベルが表示されること" do
        expect(page).to have_content '行き先名'
        expect(page).to have_content '説明'
        expect(page).to have_content '国'
      end
    end

    context "行き先登録処理" do
      it "有効なデータで登録処理で成功のフラッシュが表示されること" do
        fill_in "行き先名", with: "サンプルの行き先"
        fill_in "説明", with: "サンプルの行き先の説明です"
        fill_in "国", with: "Japan"
        click_button "登録する"
        expect(page).to have_content "Destination added!"
      end

      it "無効なデータで登録処理で失敗のフラッシュが表示されること" do
        fill_in "行き先名", with: ""
        fill_in "説明", with: "サンプルの行き先の説明です"
        fill_in "国", with: "Japan"
        click_button "登録する"
        expect(page).to have_content "行き先名を入力してください"
      end
    end
  end
end
