require 'rails_helper'

RSpec.describe "Destinations", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:destination) { create(:destination, :picture, user: user) }
  let!(:comment) { create(:comment, user_id: user.id, destination: destination) }

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
        expect(page).to have_content "スポット"
        expect(page).to have_content "国"
      end
    end

    context "行き先 登録処理" do
      it "有効なデータの登録処理で成功のフラッシュが表示されること" do
        fill_in "行き先名", with: "サンプルの行き先"
        fill_in "説明", with: "サンプルの行き先の説明です"
        fill_in "スポット", with: "サンプルの行き先のスポット"
        fill_in "国", with: "Japan"
        attach_file "destination[picture]", "#{Rails.root}/spec/fixtures/test_destination_1.jpg"
        click_button "登録する"
        expect(page).to have_content "Destination added!"
      end

      it "登録後のリダイレクト先でGoogleMap が表示されること", js: true do
        fill_in "行き先名", with: "サンプルの行き先"
        fill_in "説明", with: "サンプルの行き先の説明です"
        fill_in "スポット", with: "サンプルの行き先のスポット"
        fill_in "国", with: "Japan"
        attach_file "destination[picture]", "#{Rails.root}/spec/fixtures/test_destination_1.jpg"
        click_button "登録する"
        expect(page).to have_css "div.gm-style"
      end

      it "画像無しの登録はデフォルト画像が設定されること" do
        fill_in "行き先名", with: "サンプルの行き先"
        fill_in "説明", with: "サンプルの行き先の説明です"
        fill_in "スポット", with: "サンプルの行き先のスポット"
        fill_in "国", with: "Japan"
        click_button "登録する"
        expect(page).to have_link(href: destination_path(Destination.first))
      end

      it "無効なデータで登録処理で失敗のフラッシュが表示されること" do
        fill_in "行き先名", with: ""
        fill_in "説明", with: "サンプルの行き先の説明です"
        fill_in "スポット", with: "サンプルの行き先のスポット"
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
        expect(page).to have_link nil, href: destination_path(destination), class: "destination-picture"
      end

      it "GoogleMap が表示されていること", js: true do
        expect(page).to have_css "div.gm-style"
      end
    end

    context "GoogleMap 表示内容", js: true do
      before do
        login_for_system(user)
        visit destination_path(destination)
      end

      it "ピンが表示されていること" do
        expect(page).to have_selector "img[src$='spotlight-poi2_hdpi.png']"
      end

      it "infowindow が表示されること" do
        # map#gmimap0 要素の高さが0pxなのでvisible: false で対応
        pin = find("map#gmimap0 area", visible: false)
        pin.click
        expect(page).to have_css "div.infowindow"
      end

      it "infowindow に行き先情報が表示されること" do
        pin = find("map#gmimap0 area", visible: false)
        pin.click
        expect(page).to have_content destination.name
        expect(page).to have_content destination.spot
        expect(page).to have_content destination.country
        expect(page).to have_content destination.address
        expect(page).to have_link "GoogleMap で見る", href: "https://maps.google.co.jp/maps?q=loc:#{destination.latitude},#{destination.longitude}&iwloc=J", class: "googlemap-link"
        link = find(".googlemap-link")
        # googelmap へのリンクにtarget:"_blank"属性が付いているか
        expect(link[:target]).to eq "_blank"
      end
    end

    context "行き先 削除処理", js: true do
      it "削除成功のフラッシュが表示されること" do
        login_for_system(user)
        visit destination_path(destination)
        within('.change-destination') do
          click_on 'Delete'
        end
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content 'Destination deleted!'
      end
    end

    context "コメントの登録/削除" do
      it "自分の投稿へのコメントの登録/削除ができること" do
        login_for_system(user)
        visit destination_path(destination)
        fill_in "comment_content", with: "This is comment!"
        click_button "コメント"
        within("#comment-#{Comment.last.id}") do
          expect(page).to have_selector "span", text: user.name
          expect(page).to have_selector "span", text: "This is comment!"
        end
        expect(page).to have_content "Added a comment!"
        click_link "delete", href: comment_path(Comment.last)
        expect(page).not_to have_selector "span", text: "This is comment!"
        expect(page).to have_content "Deleted a comment!"
      end

      it "自分以外の投稿へのコメントには削除ボタンが表示されないこと" do
        login_for_system(other_user)
        visit destination_path(destination)
        within("#comment-#{comment.id}") do
          expect(page).to have_selector "span", text: user.name
          expect(page).to have_selector "span", text: comment.content
          expect(page).not_to have_link "delete", href: destination_path(destination)
        end
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
        attach_file "destination[picture]", "#{Rails.root}/spec/fixtures/test_destination_2.jpg"
        click_button "更新する"
        expect(page).to have_content "Destination updated!"
        expect(destination.reload.name).to eq "Edit destination name"
        expect(destination.reload.description).to eq "Edit destination description"
        expect(destination.reload.country).to eq "Edit country"
        expect(destination.reload.picture.url).to include "test_destination_2.jpg"
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
