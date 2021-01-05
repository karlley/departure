require 'rails_helper'

RSpec.describe "Destinations", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:destination) { create(:destination, :picture, user: user) }
  let(:destination_picture_unselected) { create(:destination, :picture_unselected, user: user) }
  let(:destination_airline_unselected) { create(:destination, :airline_unselected) }
  let!(:comment) { create(:comment, user_id: user.id, destination: destination) }
  let!(:country) { create(:country) }
  let!(:airline) { create(:airline) }

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
        expect(page).to have_content "費用"
        expect(page).to have_content "シーズン"
        expect(page).to have_content "体験"
        expect(page).to have_content "航空会社"
        expect(page).to have_content "食べ物"
      end

      it "DB 読み込みのプルダウンリストが正しく表示されること" do
        # Country
        country_data = Country.pluck("country_name") # モデルから特定カラムを配列化
        country_pulldown = nil
        within find_field("国") do
          country_pulldown = all("option").map(&:text).to_ary.drop(1) # プルダウンリストのプロンプトを削除して配列化
        end
        expect(country_pulldown).to eq country_data
        # Airline
        airline_data = Airline.pluck("airline_name")
        airline_pulldown = nil
        within find_field("航空会社") do
          airline_pulldown = all("option").map(&:text).to_ary.drop(1)
        end
        expect(airline_pulldown).to eq airline_data
      end
    end

    context "行き先 登録処理" do
      before do
        fill_in "行き先名", with: "サンプルの行き先"
        fill_in "説明", with: "サンプルの行き先の説明"
        fill_in "スポット", with: "サンプルの行き先のスポット"
        select "日本", from: "国"
        select "￥100,000 ~ ￥200,000", from: "費用"
        select "1月", from: "シーズン"
        fill_in "体験", with: "サンプルの体験"
        select "日本航空", from: "航空会社"
        fill_in "食べ物", with: "サンプルの食べ物"
        attach_file "destination[picture]", "#{Rails.root}/spec/fixtures/test_destination_1.jpg"
      end

      it "有効なデータの登録処理で成功のフラッシュが表示されること" do
        click_button "登録する"
        expect(page).to have_content "Destination added!"
      end

      it "登録後のリダイレクト先でGoogleMap が表示されること", js: true do
        click_button "登録する"
        expect(page).to have_css "div.gm-style"
      end

      it "画像無しの登録はデフォルト画像が設定されること" do
        attach_file nil
        click_button "登録する"
        # リンクテキスト: nil で画像を指定, class 指定で画像に絞り込み, 登録後のページ(show) で画像リンクを確認
        expect(page).to have_link nil, href: destination_path(Destination.first), class: "destination-picture"
      end

      it "無効なデータで登録処理で失敗のフラッシュが表示されること" do
        fill_in "行き先名", with: ""
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
        # FactroyBot で生成した値から国のデータを取得 > 国名を取得
        country_name = Country.find_by(id: destination.country).country_name
        region = Country.find_by(id: destination.country).region
        expect(page).to have_content country_name
        expect(page).to have_content region
        expect(page).to have_content destination.expense
        expect(page).to have_content destination.season
        expect(page).to have_content destination.experience
        expect(page).to have_content destination.food
        expect(page).to have_content destination.description
        # リンクテキスト: nil で画像を指定, class 指定で画像に絞り込み, 登録後のページ(show) で画像リンクを確認
        expect(page).to have_link nil, href: destination_path(destination), class: "destination-picture"
      end

      it "航空会社が選択された場合は航空会社とアライアンスが表示される" do
        airline_name = Airline.find_by(id: destination.airline).airline_name
        alliance = Airline.find_by(id: destination.airline).alliance
        expect(page).to have_selector ".destination-airline_name", text: airline_name
        expect(page).to have_selector ".destination-alliance", text: alliance
      end

      it "航空会社が未選択の場合には航空会社に'未使用'が表示され, アライアンスは非表示になる" do
        # 航空会社が選択されていないFactory を使用
        visit destination_path(destination_airline_unselected)
        expect(page).to have_selector ".destination-airline_name", text: "未使用"
        # アライアンスの非表示を確認
        expect(page).not_to have_css ".destination-alliance"
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

  describe "Destination Search ページ" do
    context "ページレイアウト" do
      context "ログインしている場合" do
        it "各ページに検索バーが表示されていること" do
          login_for_system(user)
          visit root_path
          expect(page).to have_css "form#destination_search"
          visit about_path
          expect(page).to have_css "form#destination_search"
          visit notifications_path
          expect(page).to have_css "form#destination_search"
          visit favorites_path
          expect(page).to have_css "form#destination_search"
          # user
          visit users_path
          expect(page).to have_css "form#destination_search"
          visit user_path(user)
          expect(page).to have_css "form#destination_search"
          visit edit_user_path(user)
          expect(page).to have_css "form#destination_search"
          visit following_user_path(user)
          expect(page).to have_css "form#destination_search"
          visit followers_user_path(user)
          expect(page).to have_css "form#destination_search"
          # destination
          visit destination_path(destination)
          expect(page).to have_css "form#destination_search"
          visit destinations_path
          expect(page).to have_css "form#destination_search"
          visit new_destination_path
          expect(page).to have_css "form#destination_search"
          visit edit_destination_path(destination)
          expect(page).to have_css "form#destination_search"
        end
      end

      context "未ログインの場合" do
        it "検索バーが表示されないこと" do
          visit root_path
          expect(page).not_to have_css "form#destination_search"
        end
      end
    end

    context "検索機能" do
      before do
        login_for_system(user)
      end

      it "feed から検索ワードに該当する結果が表示されること" do
        search_word = "東京"
        create(:destination, name: search_word, user: user)
        fill_in "q_name_cont", with: search_word
        click_button "Search"
        expect(page).to have_css "h1", text: "\"#{search_word}\" Search Results : 1"
        within(".destinations") do
          expect(page).to have_css "li", count: 1
        end
      end

      it "検索ワードを入力しなかった場合は行き先一覧が表示されること" do
        fill_in "q_name_cont", with: " "
        click_button "Search"
        expect(page).to have_css "h1", text: "All Destinations"
        within(".destinations") do
          expect(page).to have_css "li", count: Destination.count
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
        expect(page).to have_content "スポット"
        expect(page).to have_content "国"
        expect(page).to have_content "費用"
        expect(page).to have_content "シーズン"
        expect(page).to have_content "体験"
        expect(page).to have_content "航空会社"
        expect(page).to have_content "食べ物"
      end
    end

    context "行き先 更新処理" do
      it "有効な更新" do
        fill_in "行き先名", with: "サンプルの行き先"
        fill_in "説明", with: "サンプルの行き先の説明"
        fill_in "スポット", with: "サンプルの行き先のスポット"
        select "日本", from: "国"
        select "￥10,000 ~ ￥50,000", from: "費用"
        select "1月", from: "シーズン"
        fill_in "体験", with: "サンプルの体験"
        select "日本航空", from: "航空会社"
        fill_in "食べ物", with: "サンプルの食べ物"
        attach_file "destination[picture]", "#{Rails.root}/spec/fixtures/test_destination_2.jpg"
        click_button "更新する"
        # 更新されたcountry を元にCSV から国名を取得
        country_name = Country.find_by(id: destination.reload.country).country_name
        # 更新されたexpense を月表示の文字列に変換
        season = destination.reload.season.to_s + "月"
        # 更新されたairline を元にCSV から航空会社名を取得
        airline_name = Airline.find_by(id: destination.reload.airline).airline_name
        expect(page).to have_content "Destination updated!"
        expect(destination.reload.name).to eq "サンプルの行き先"
        expect(destination.reload.description).to eq "サンプルの行き先の説明"
        expect(destination.reload.spot).to eq "サンプルの行き先のスポット"
        expect(country_name).to eq "日本"
        expect(destination.reload.expense).to eq "￥10,000 ~ ￥50,000"
        expect(season).to eq "1月"
        expect(destination.reload.experience) .to eq "サンプルの体験"
        expect(airline_name).to eq "日本航空"
        expect(destination.reload.food).to eq "サンプルの食べ物"
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
