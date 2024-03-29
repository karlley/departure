require 'rails_helper'

RSpec.describe "Destinations", type: :system do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:admin_user) { create(:user, :admin) }
  let!(:destination) { create(:destination, :picture, user: user) }
  let!(:destination_admin_user) { create(:destination, :picture, user: admin_user) }
  let!(:destination_other_user) { create(:destination, :picture, user: other_user) }
  let(:destination_picture_unselected) { create(:destination, :picture_unselected, user: user) }
  let(:destination_airline_unselected) { create(:destination, :airline_unselected) }
  let(:destination_picture_unselected) { create(:destination, :picture_unselected, user: user) }
  let!(:comment) { create(:comment, user_id: user.id, destination: destination) }
  # 自分以外の投稿に自分がコメント
  let!(:comment_add_other_user_destination) { create(:comment, user_id: user.id, destination: destination_other_user) }
  let!(:country) { create(:country) }
  let!(:airline) { create(:airline) }

  describe "destinations#new" do
    before do
      login_for_system(user)
      visit new_destination_path
    end

    context "ページレイアウト" do
      it "'シェア' の文字列が存在すること" do
        expect(page).to have_content "シェア"
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("シェア")
      end

      it "写真選択フォームが表示されていること" do
        expect(page).to have_content "行き先の写真"
      end

      it "写真が非表示であること" do
        within(".destination-form-picture-select") do
          expect(page).not_to have_selector "img"
        end
      end

      it "入力フォームに正しいラベルが表示されること" do
        within(".destination-form-wrapper") do
          expect(page).to have_content "行き先名"
          expect(page).to have_content "説明"
          expect(page).to have_content "スポット"
          expect(page).to have_content "地域"
          expect(page).to have_content "費用"
          expect(page).to have_content "シーズン"
          expect(page).to have_content "体験"
          expect(page).to have_content "航空会社"
          expect(page).to have_content "食べ物"
        end
      end

      it "DB のデータを使ったセレクトボックスが正しく表示されること" do
        # 地域
        region_db_data = Country.where(region: nil).pluck("country_name") # Country モデルから地域名のみのcountry_name カラムを配列化
        region_selectbox = nil
        within find_field("地域") do
          region_selectbox = all("option").map(&:text).to_ary.drop(1) # プロンプト削除
          region_selectbox.delete_at(-1) # 配列末尾のcountry_name 削除
        end
        expect(region_selectbox).to eq region_db_data

        # 航空会社
        airline_db_data = Airline.pluck("airline_name") # Airline モデルからairline_name カラムを配列化
        airline_selectbox = nil
        within find_field("航空会社") do
          airline_selectbox = all("option").map(&:text).to_ary.drop(1) # プロンプト削除
        end
        expect(airline_selectbox).to eq airline_db_data
      end
    end

    context "地域、国選択の動的セレクトボックス" do
      before do
        login_for_system(user)
        visit new_destination_path
      end

      it "地域が選択されるまで国のセレクトボックスが表示されないこと" do
        expect(page).not_to have_css "#destination_country#country_select_box"
      end

      it "地域が選択されると国のセレクトボックスが表示されること", js: true do
        # FIXME: 国のセレクトボックスが表示されない
        # expect(page).not_to have_css "#country_select_box"
        # select "アジア", from: "地域"
        # expect(page).to have_css "#country_select_box"
      end

      it "地域の選択に合わせた国の選択肢が表示される" do
      end

      it "地域が未選択になると国のセレクトボックスが非表示になる" do
      end
    end

    # FIXME: 国のセレクトボックスが表示されないので登録処理が不可
    context "行き先 登録処理" do
      before do
        fill_in "行き先名", with: "サンプルの行き先"
        fill_in "説明", with: "サンプルの行き先の説明"
        fill_in "スポット", with: "サンプルの行き先のスポット"
        select "アジア", from: "地域"
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
        # リンクテキスト: nil で画像を指定, class 指定で画像に絞り込み, destinations#show ページで画像リンクを確認
        # expect(page).to have_link nil, href: destination_path(Destination.first), class: "destination-show-picture"
        expect(page).to have_selector ".destination-show-picture img"
      end

      it "無効なデータで登録処理で失敗のフラッシュが表示されること" do
        fill_in "行き先名", with: ""
        click_button "登録する"
        expect(page).to have_content "行き先名を入力してください"
      end
    end
  end

  describe "destinations#index" do
    context "ユーザ毎の行き先表示を確認" do
      before do
        login_for_system(user)
        visit destinations_path
      end

      it "自分の行き先の表示を確認" do
        expect(page).to have_content destination.name
        expect(page).to have_content destination.user.name
      end

      it "自分以外のユーザの行き先の表示を確認" do
        expect(page).to have_content destination_other_user.name
        expect(page).to have_content destination_other_user.user.name
      end
    end

    context "ページレイアウト" do
      before do
        login_for_system(user)
        visit destinations_path
      end

      it "GoogleMap が表示されていること", js: true do
        expect(page).to have_css "div.gm-style"
      end

      # FIXME: ピンが表示されないことがあるのでfactorybot 要修正
      # it "GoogleMap のピンが行き先の件数分表示されていること",js: true do
      #   post_count = Destination.count
      #   expect(page).to have_css "img[src$='spotlight-poi2_hdpi.png']", count: post_count
      # end

      it "旅先の情報が正しく表示されている事を確認" do
        expect(page).to have_css "div.destination-list-picture img"
        # 旅先画像の表示を確認
        expect(page).to have_link nil, href: destination_path(destination), class: "destination-list-picture-link"
        # アイコンの表示を確認
        expect(page).to have_css "div.destination-list-icon img.gravatar"
        expect(page).to have_link nil, href: user_path(destination.user), class: "destination-list-icon-link"
        expect(page).to have_link destination.name.truncate(30), href: destination_path(destination)
        expect(page).to have_link destination.user.name, href: user_path(destination.user)
        # 50文字以上を省略しているのも検証
        expect(page).to have_content destination.description.truncate(50)
        country_name = get_country_name(destination).truncate(10)
        expect(page).to have_content country_name
        expect(page).to have_content "いいね!"
        expect(page).to have_css "div.destination-list-timestamp"
      end
    end

    context "行き先が複数ある場合の表示" do
      it "ページネーションの表示を確認" do
        login_for_system(user)
        # per_page が12件なので13件のテストデータを作成
        create_list(:destination, 13, user: user)
        visit destinations_path
        expect(page).to have_content "すべての旅先"
        expect(page).to have_css "div.pagination"
        Destination.take(12).each do |d|
          expect(page).to have_link d.name.truncate(30)
        end
      end
    end
  end

  describe "destinations#show" do
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
        expect(page).to have_content destination.address
        expect(page).to have_link "GoogleMap で見る", href: "https://maps.google.co.jp/maps?q=loc:#{destination.latitude},#{destination.longitude}&iwloc=J", class: "googlemap-link"
        link = find(".googlemap-link")
        # googelmap へのリンクにtarget:"_blank"属性が付いているか
        expect(link[:target]).to eq "_blank"
      end
    end

    context "行き先の編集/削除ボタンがユーザ毎の表示" do
      it "投稿者、管理者のみ3点リーダが表示される" do
        login_for_system(user)
        visit destination_path(destination)
        expect(page).to have_css "button.dropdown-toggle.destination-show-dropdown-toggle"
        logout
        login_for_system(admin_user)
        visit destination_path(destination_admin_user)
        expect(page).to have_css "button.dropdown-toggle.destination-show-dropdown-toggle"
      end

      it "投稿者のみ編集ボタンが表示される" do
        login_for_system(user)
        visit destination_path(destination)
        button = find "button.dropdown-toggle.destination-show-dropdown-toggle"
        button.click
        expect(page).to have_link "旅先を編集する", href: edit_destination_path(destination)
      end

      it "投稿者、管理者のみ削除ボタンが表示される" do
        login_for_system(user)
        visit destination_path(destination)
        button = find "button.dropdown-toggle.destination-show-dropdown-toggle"
        button.click
        expect(page).to have_link "旅先を削除する", href: destination_path(destination)
        logout
        login_for_system(admin_user)
        visit destination_path(destination_admin_user)
        button = find "button.dropdown-toggle.destination-show-dropdown-toggle"
        button.click
        expect(page).to have_link "旅先を削除する", href: destination_path(destination_admin_user)
      end
    end

    context "行き先 削除処理", js: true do
      it "削除成功のフラッシュが表示されること" do
        login_for_system(admin_user)
        visit destination_path(destination_admin_user)
        button = find "button.dropdown-toggle.destination-show-dropdown-toggle"
        button.click
        within('ul.dropdown-menu.destination-show-edit-delete') do
          click_on '旅先を削除する'
        end
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content 'Destination deleted!'
      end
    end

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

      it "行き先の投稿者の情報が表示されること" do
        expect(page).to have_link nil, href: user_path(destination.user), class: "destination-list-icon-link"
        expect(page).to have_link destination.user.name, href: user_path(destination.user)
      end

      it "GoogleMap が表示されていること", js: true do
        expect(page).to have_css "div.gm-style"
      end

      it "行き先の写真が表示されること" do
        expect(page).to have_selector "img[src$='test_destination_1.jpg']"
      end

      it "いいね! ボタンが表示されること" do
        expect(page).to have_link, href: "/favorites/destination.id/create"
        expect(page).to have_selector "span.favorite-btn-favorite"
        expect(page).to have_selector "i.far.fa-heart"
        expect(page).to have_content "いいね!"
      end

      it "行き先投稿のタイムスタンプが表示されること" do
        expect(page).to have_selector "div.destination-show-timestamp", text: "1分以内"
      end

      it "行き先情報が表示されること" do
        expect(page).to have_selector "div.destination-show-description p", text: destination.description
        # FactroyBot で生成した値から国のデータを取得 > 国名を取得
        country_name = Country.find_by(id: destination.country_id).country_name
        region = Country.find_by(id: destination.country_id).region
        expect(page).to have_selector "p.destination-show-country-name", text: country_name
        expect(page).to have_selector "p.destination-show-region", text: region
        expect(page).to have_selector "p.destination-show-spot", text: destination.spot
        expect(page).to have_selector "p.destination-show-expense", text: destination.expense
        expect(page).to have_selector "p.destination-show-season", text: destination.season
        expect(page).to have_selector "p.destination-show-experience", text: destination.experience
        airline_name = Airline.find_by(id: destination.airline_id).airline_name
        alliance = Airline.find_by(id: destination.airline_id).alliance
        expect(page).to have_selector ".destination-show-airline-name", text: airline_name
        expect(page).to have_selector ".destination-show-alliance", text: alliance
        expect(page).to have_selector "p.destination-show-food", text: destination.food
      end

      it "コメントの情報が表示されること" do
        expect(page).to have_selector "div.destination-show-comment-wrapper"
        expect(page).to have_selector "h2", text: "コメント (1)"
        expect(page).to have_link nil, href: user_path(comment.user_id), class: "destination-comment-icon-link"
        # コメント投稿者の名前を取得
        comment_user = User.find(comment.user_id).name
        expect(page).to have_link comment_user, href: user_path(comment.user_id)
        expect(page).to have_selector "div.destination-comment-time", text: "1分以内"
        expect(page).to have_selector "div.destination-comment-content p", text: comment.content
      end
    end

    context "アライアンスの表示/非表示" do
      it "航空会社が未選択の場合には航空会社に'飛行機は使っていない'が表示され, アライアンスは非表示になること" do
        login_for_system(user)
        # 航空会社が選択されていないFactory を使用
        visit destination_path(destination_airline_unselected)
        expect(page).to have_selector ".destination-show-airline-name", text: "飛行機は使っていない"
        # アライアンスの非表示を確認
        expect(page).not_to have_css ".destination-show-alliance"
      end
    end

    context "コメントの登録/削除" do
      it "自分の投稿へのコメントの登録/削除ができること" do
        login_for_system(user)
        visit destination_path(destination)
        fill_in "comment_content", with: "This is comment!"
        click_button "コメント"
        within("#comment-#{Comment.last.id}") do
          expect(page).to have_selector "div.destination-comment-content p", text: "This is comment!"
        end
        expect(page).to have_content "Added a comment!"
        click_link "delete", href: comment_path(Comment.last)
        expect(page).not_to have_selector "div.destination-comment-content p", text: "This is comment!"
        expect(page).to have_content "Deleted a comment!"
      end

      it "自分以外の投稿へのコメントができること" do
        login_for_system(user)
        visit destination_path(destination_other_user)
        fill_in "comment_content", with: "This is comment!"
        click_button "コメント"
        within("#comment-#{Comment.last.id}") do
          expect(page).to have_selector "div.destination-comment-content p", text: "This is comment!"
        end
      end

      it "自分以外の投稿へのコメントには削除ボタンが表示されないこと(自分の投稿のみコメント削除できる)" do
        login_for_system(user)
        visit destination_path(destination_other_user)
        # 自分以外の投稿のコメントの中から自分のコメントに絞り込み
        within("#comment-#{comment_add_other_user_destination.id}") do
          expect(page).not_to have_link "delete", href: destination_path(destination_other_user)
        end
      end
    end
  end

  describe "destination 検索フォーム" do
    context "ログイン状態での検索フォームの表示確認" do
      context "ログインしている場合" do
        it "各ページに検索フォームが表示されていること" do
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

      context "未ログイン時の検索フォームの表示" do
        it "検索フォームが表示されないこと" do
          visit root_path
          expect(page).not_to have_css "form#destination_search"
        end
      end
    end

    context "検索結果の検証" do
      before do
        login_for_system(user)
      end

      it "検索ワードから行き先名 にマッチする結果が表示されること", js: true do
        search_word = "東京"
        create(:destination, name: search_word, user: user)
        # id に#header_keyword_search を指定
        fill_in "header_keyword_search", with: search_word
        # Enter キー押下
        find("#header_keyword_search").send_keys :return
        expect(page).to have_css "h1", text: "\"#{search_word}\" 検索結果 : 1"
        expect(page).to have_css "div.destination-list-post", count: 1
      end

      it "検索ワードからスポット にマッチする結果が表示されること", js: true do
        search_word = "タワー"
        create(:destination, spot: search_word, user: user)
        # id に#header_keyword_search を指定
        fill_in "header_keyword_search", with: search_word
        # Enter キー押下
        find("#header_keyword_search").send_keys :return
        expect(page).to have_css "h1", text: "\"#{search_word}\" 検索結果 : 1"
        expect(page).to have_css "div.destination-list-post", count: 1
      end

      it "検索ワードから住所 にマッチする結果が表示されること", js: true do
        search_word = "東京都"
        create(:destination, address: search_word, user: user)
        # id に#header_keyword_search を指定
        fill_in "header_keyword_search", with: search_word
        # Enter キー押下
        find("#header_keyword_search").send_keys :return
        expect(page).to have_css "h1", text: "\"#{search_word}\" 検索結果 : 1"
        expect(page).to have_css "div.destination-list-post", count: 1
      end

      it "複数の検索ワードでマッチする結果が表示されること", js: true do
        search_word = "東京 タワー"
        create(:destination, name: "東京", spot: "タワー", user: user)
        # id に#header_keyword_search を指定
        fill_in "header_keyword_search", with: search_word
        # Enter キー押下
        find("#header_keyword_search").send_keys :return
        expect(page).to have_css "h1", text: "\"#{search_word}\" 検索結果 : 1"
        expect(page).to have_css "div.destination-list-post", count: 1
      end

      it "検索ワードを入力しなかった場合は行き先一覧が表示されること", js: true do
        # 全投稿数を取得
        post_count = Destination.count
        # id に#header_keyword_search を指定
        fill_in "header_keyword_search", with: ""
        # Enter キー押下
        find("#header_keyword_search").send_keys :return
        expect(page).to have_css "h1", text: "すべての旅先"
        expect(page).to have_css "div.destination-list-post", count: post_count
      end
    end
  end

  describe "destinations#edit" do
    before do
      login_for_system(user)
      visit destination_path(destination)
      button = find "button.dropdown-toggle.destination-show-dropdown-toggle"
      button.click
      click_link "旅先を編集する"
    end

    context "ページレイアウト" do
      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("Edit Destination")
      end

      it "'Edit + 行き先名' の文字列が存在すること" do
        expect(page).to have_content "#{destination.name}"
      end

      it "写真選択フォームが表示されていること" do
        expect(page).to have_content "行き先の写真"
      end

      it "登録済みの画像が表示されること" do
        expect(page).to have_selector "img[src$='test_destination_1.jpg']"
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

    # FIXME: 国のセレクトボックスが表示されないので更新処理が不可
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
        # 更新されたcountry_id を元にCSV から国名を取得
        country_name = Country.find_by(id: destination.reload.country_id).country_name
        # 更新されたexpense を月表示の文字列に変換
        season = destination.reload.season.to_s + "月"
        # 更新されたairline を元にCSV から航空会社名を取得
        airline_name = Airline.find_by(id: destination.reload.airline_id).airline_name
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
        click_on "削除する"
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content 'Destination deleted!'
      end
    end
  end
end
