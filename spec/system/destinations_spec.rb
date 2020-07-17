require 'rails_helper'

RSpec.describe "Destinations", type: :system do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  describe "New Destination ページ" do
    before do
      login_for_system(user)
      visit new_destination_path
    end

    context "ページレイアウト" do
      it "'New Destination' の文字列が存在すること" do
        expect(page).to have_content "New Destination"
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("New Destination")
      end

      it "入力フォームに正しいラベルが表示されること" do
        expect(page).to have_content "行き先名"
        expect(page).to have_content "説明"
        expect(page).to have_content "国"
      end
    end

    context "行き先 登録処理" do
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

  describe "Destination ページ" do
    context "ページレイアウト" do
      before do
        login_for_system(user)
        visit destination_path(destination)
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("#{destination.name}")
      end

      it "'行き先名' の文字列が存在すること" do
        expect(page).to have_content "#{destination.name}"
      end

      it "行き先情報が表示されること" do
        expect(page).to have_content destination.name
        expect(page).to have_content destination.country
        expect(page).to have_content destination.description
      end
    end

    context "行き先 削除処理", js: true do
      it "削除成功のフラッシュが表示されること" do
        login_for_system(user)
        visit destination_path(destination)
        within find('.change-destination') do
          click_on 'Delete'
        end
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content 'Destination deleted!'
      end
    end
  end

  describe "Destination Edit ページ" do
    before do
      login_for_system(user)
      visit destination_path(destination)
      click_link "Edit"
    end

    context "ページレイアウト" do
      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("Edit Destination")
      end

      it "'Edit + 行き先名' の文字列が存在すること" do
        expect(page).to have_content "Edit #{destination.name}"
      end

      it "入力フォームに適切なラベルが表示されること" do
        expect(page).to have_content "行き先名"
        expect(page).to have_content "説明"
        expect(page).to have_content "国"
      end
    end

    context "行き先 更新処理" do
      it "有効な更新" do
        fill_in "行き先名", with: "Edit destination name"
        fill_in "説明", with: "Edit destination description"
        fill_in "国", with: "Edit country"
        click_button "更新する"
        expect(page).to have_content "Destination updated!"
        expect(destination.reload.name).to eq "Edit destination name"
        expect(destination.reload.description).to eq "Edit destination description"
        expect(destination.reload.country).to eq "Edit country"
      end

      it "無効な更新" do
        fill_in "行き先名", with: ""
        click_button "更新する"
        expect(page).to have_content "行き先名を入力してください"
        expect(destination.reload.name).not_to eq ""
      end
    end

    context "行き先 削除処理", js: true do
      it "削除成功のフラッシュが表示されること" do
        click_on '行き先を削除する'
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content 'Destination deleted!'
      end
    end
  end
end
