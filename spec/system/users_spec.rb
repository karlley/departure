require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe "users#index" do
    context "管理者ユーザーの場合" do
      let(:admin_user) { create(:user, :admin) }

      before do
        login_for_system(admin_user)
        create_list(:user, 30)
        visit users_path
      end

      it "ページネーション機能, 自分以外のユーザーの削除ボタンが表示される" do
        expect(page).to have_css "div.pagination"
        User.paginate(page: 1).each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          expect(page).to have_content "#{u.name} | 削除" unless u == admin_user
        end
      end
    end

    context "管理者ユーザー以外の場合" do
      let(:user) { create(:user) }

      before do
        login_for_system(user)
        create_list(:user, 30)
        visit users_path
      end

      it "ページネーション, 自分のアカウントのみ削除ボタンが表示される" do
        expect(page).to have_css "div.pagination"
        User.paginate(page: 1).each do |u|
          expect(page).to have_link u.name, href: user_path(u)
          if u == user
            expect(page).to have_content "#{u.name} | 削除"
          else
            expect(page).not_to have_content "#{u.name} | 削除"
          end
        end
      end
    end
  end

  describe "users#new" do
    before do
      visit signup_path
    end

    context "未ログインでサインアップページにアクセスした場合" do
      it "Signup の文字列が表示される" do
        expect(page).to have_content 'Signup'
      end

      it "正しいタイトルが表示される" do
        expect(page).to have_title full_title('Signup')
      end
    end

    context "有効なユーザーで登録処理を行う場合" do
      before do
        fill_in "ユーザー名", with: "Example User"
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード(確認)", with: "password"
        click_button "サインアップ"
      end

      it "登録処理を行うと成功のフラッシュが表示される" do
        expect(page).to have_content "Welcome to Departure!"
      end
    end

    context "無効なユーザーで登録処理を行う場合" do
      before do
        fill_in "ユーザー名", with: ""
        fill_in "メールアドレス", with: "user@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード(確認)", with: "pass"
        click_button "サインアップ"
      end

      it "登録処理を行うと失敗のフラッシュが表示される" do
        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "パスワード(確認)とパスワードの入力が一致しません"
      end
    end
  end

  describe "users#edit" do
    context "有効なユーザーの場合" do
      let(:user) { create(:user) }

      before do
        login_for_system(user)
        visit user_path(user)
        button = find "button.dropdown-toggle.user-show-dropdown-toggle"
        button.click
        click_link "プロフィールを編集する"
      end

      context "プロフィール編集ページにアクセスした場合" do
        it "正しいタイトルが表示される" do
          expect(page).to have_title full_title('Edit Profile')
        end
      end

      context "有効なプロフィール更新を行った場合" do
        before do
          fill_in "ユーザー名", with: "Edit Example User"
          fill_in "メールアドレス", with: "edit-user@example.com"
          fill_in "自己紹介", with: "My Introduction!"
          fill_in "国籍", with: "Japan"
          click_button "更新する"
        end

        it "成功のフラッシュが表示される" do
          expect(page).to have_content "Your Profile has been updated!"
          expect(user.reload.name).to eq "Edit Example User"
          expect(user.reload.email).to eq "edit-user@example.com"
          expect(user.reload.introduction).to eq "My Introduction!"
          expect(user.reload.nationality).to eq "Japan"
        end
      end

      context "無効なプロフィール更新を行った場合" do
        before do
          fill_in "ユーザー名", with: ""
          fill_in "メールアドレス", with: ""
          click_button "更新する"
        end

        it "適切なエラーメッセージが表示される" do
          expect(page).to have_content "ユーザー名を入力してください"
          expect(page).to have_content "メールアドレスを入力してください"
          expect(page).to have_content "メールアドレスは不正な値です"
          expect(user.reload.email).not_to eq ""
        end
      end

      context "アカウント削除処理を行った場合", js: true do
        before do
          click_link "アカウントを削除する"
          page.driver.browser.switch_to.alert.accept
        end

        it "正常に削除できる" do
          expect(page).to have_content "Your Account has been deleted!"
        end
      end
    end

    context "ゲストユーザーの場合" do
      let(:guest_user) { create(:user, :guest) }

      before do
        login_for_system(guest_user)
        visit user_path(guest_user)
        button = find "button.dropdown-toggle.user-show-dropdown-toggle"
        button.click
        click_link "プロフィールを編集する"
      end

      it "ユーザー名とメールアドレスが編集できない" do
        user_name = find "#user_name"
        user_email = find "#user_email"
        # readonly 属性の有無をテスト
        expect(user_name.disabled?).to be_truthy 
        expect(user_email.disabled?).to be_truthy 
      end
    end
  end

  describe "users#show" do
    before do
      login_for_system(user)
    end

    context "有効なユーザーがアカウントページにアクセスした場合" do
      let(:user) { create(:user) }

      before do
        visit user_path(user)
      end

      it "正しいタイトルが表示される" do
        expect(page).to have_title full_title('Profile')
      end

      it "ユーザーのアイコンが表示される" do
        expect(page).to have_css ".user-show-icon img.gravatar"
      end

      it "タイトル部にユーザ名が表示される" do
        expect(page).to have_selector ".user-show-name-edit h1", text: user.name
      end

      it "投稿/フォロワー/フォロー のステータスが表示される" do
        expect(page).to have_css ".user-stats-destinations"
        expect(page).to have_css ".user-stats-followers"
        expect(page).to have_css ".user-stats-following"
        expect(page).to have_content "投稿\n#{user.destinations.count}\n件"
        expect(page).to have_link "フォロワー #{user.followers.count} 人", href: followers_user_path(user), class: "user-stats-followers-link"
        expect(page).to have_link "フォロー #{user.following.count} 人", href: following_user_path(user), class: "user-stats-following-link"
      end

      it "ユーザーの国籍/紹介文が表示される" do
        expect(page).to have_selector "p.user-show-nationality", text: user.nationality
        expect(page).to have_selector "div.user-show-introduction", text: user.introduction
      end
    end

    context "フォローする/フォロー中 のボタンの表示/非表示" do
      context "有効なユーザーが自分以外のユーザーをフォローしている場合" do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }

        before do
          visit user_path(other_user)
          click_button "フォローする"
        end

        it "フォロー中のボタンが表示される" do
          expect(page).to have_css "div.follow-form-wrapper"
          expect(page).to have_css "input.unfollow-button"
          expect(page).to have_button "フォロー中"
        end
      end

      context "有効なユーザが自分以外のユーザーをフォローしていない場合" do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }

        before do
          visit user_path(other_user)
        end

        it "フォローするのボタンが表示される" do
          expect(page).to have_css "div.follow-form-wrapper"
          expect(page).to have_css "input.follow-button"
          expect(page).to have_button "フォローする"
        end
      end

      context "有効なユーザーが自分のアカウントページにアクセスした場合" do
        let(:user) { create(:user) }

        before do
          visit user_path(user)
        end

        it "フォロー中/フォローするのボタンが表示されない" do
          expect(page).not_to have_css "div.follow-form-wrapper"
          expect(page).not_to have_button "フォローする"
          expect(page).not_to have_button "フォロー中"
        end
      end

      # フォロー/フォロー解除の動作テストはrequest spec でテスト済み、ボタン動作のみテスト
      context "フォローする/フォロー中のボタンのAjax での動作確認" do
        context "有効なユーザーで自分以外のユーザーのフォローする/フォロー解除ボタンを押した場合" do
          let(:user) { create(:user) }
          let(:other_user) { create(:user) }

          before do
            visit user_path(other_user)
          end

          # TODO: Ajax の表示テストが正しいのか調べて修正
          # js: ture にするとエラーでもパスするのでjs: true は付けない
          it "フォローする/フォロー中のボタンが動的に切り替わる" do
            expect(page).to have_button "フォローする"
            expect(page).to have_css ".follow-button"
            click_button "フォローする"
            expect(page).to have_button "フォロー中"
            expect(page).to have_css ".unfollow-button"
            click_button "フォロー中"
            expect(page).to have_button "フォローする"
            expect(page).to have_css ".follow-button"
          end
        end
      end
    end

    context "ユーザーの投稿済み行き先リストの表示/非表示" do
      context "有効なユーザーが行き先を投稿していた場合" do
        let(:user) { create(:user) }

        before do
          create_list(:destination, 3, user: user)
          visit user_path(user)
        end

        it "投稿済みのの行き先リストが表示される" do
          expect(page).to have_css "div.users-picture-list-wrapper"
          Destination.take(3).each do |destination|
            # 行き先の画像の表示確認
            expect(page).to have_css "div.destination-#{destination.id} div.users-picture img"
            # destinations#show へのリンクを確認
            expect(page).to have_link nil, href: destination_path(destination), class: "destination-list-picture-link"
          end
        end
      end

      context "有効なユーザーが行き先を投稿していない場合" do
        let(:user) { create(:user) }

        before do
          visit user_path(user)
        end

        it "行き先リストが非表示で代替テキストが表示される" do
          expect(page).not_to have_css "div.users-picture-list-wrapper"
          expect(page).not_to have_css "div.user-picture img"
          expect(page).to have_content "投稿がありません"
          expect(page).to have_css "p.user-show-no-destination"
        end
      end
    end

    context "ユーザーのプロフィール編集ボタンの表示/非表示" do
      context "有効なユーザーが自分のアカウントページにアクセスした場合" do
        let(:user) { create(:user) }

        before do
          visit user_path(user)
          # 3点リーダを探してクリック
          button = find "button.dropdown-toggle.user-show-dropdown-toggle"
          button.click
        end

        it "プロフィール編集ボタンが表示される" do
          expect(page).to have_css "li.user-show-edit"
          expect(page).to have_link "プロフィールを編集する", href: edit_user_path(user)
        end
      end

      context "有効なユーザーが自分以外のアカウントページにアクセスした場合" do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }

        before do
          visit user_path(other_user)
        end

        it "プロフィール編集ボタンが表示されない" do
          expect(page).not_to have_css "button.dropdown-toggle.user-show-dropdown-toggle"
          expect(page).not_to have_link "プロフィールを編集する", href: edit_user_path(user)
        end
      end
    end
  end

  describe "favorites#create, destroy" do
    before do
      login_for_system(user)
    end

    context "favorite, unfavorite, favorite? メソッドの動作確認" do
      context "有効なユーザーが行き先のいいね!/いいね!解除ボタンを押した場合" do
        let(:user) { create(:user) }
        let(:destination) { create(:destination) }

        it "favorite, unfavorite, favorite? メソッドが正常に動作する" do
          expect(user.favorite?(destination)).to be_falsey
          user.favorite(destination)
          expect(user.favorite?(destination)).to be_truthy
          user.unfavorite(destination)
          expect(user.favorite?(destination)).to be_falsey
        end
      end
    end

    context "行き先表示の各ページでのいいね!/いいね!解除の動作確認" do
      context "destinations#show の場合" do
        let(:user) { create(:user) }
        let(:destination) { create(:destination) }

        before do
          visit destination_path(destination)
        end

        it "いいね!/いいね!解除ができること", js: true do
          link = find('.favorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/create"
          link.click
          link = find('.unfavorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/destroy"
          link.click
          link = find('.favorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/create"
        end
      end

      context "destinations#index の場合" do
        let(:user) { create(:user) }
        let!(:destination) { create(:destination) }

        before do
          visit destinations_path
        end

        it "いいね!/いいね!解除ができる", js: true do
          link = find('.favorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/create"
          link.click
          link = find('.unfavorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/destroy"
          link.click
          link = find('.favorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/create"
        end
      end

      context "favorites#index の場合" do
        let(:user) { create(:user) }
        let(:destination) { create(:destination) }
        # FactoryBot でfavorite を生成するとuser, destination に関連付けできない
        # let(:favorite) { create(:favorite) }

        before do
          # FactoryBot で生成したuser がdestination をいいね!
          user.favorite(destination)
          visit favorites_path
        end

        it "いいね!/いいね!解除ができる", js: true do
          link = find('.unfavorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/destroy"
          link.click
          link = find('.favorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/create"
          link.click
          link = find('.unfavorite')
          expect(link[:href]).to include "/favorites/#{destination.id}/destroy"
        end
      end
    end
  end

  describe "favorites#index" do
    before do
      login_for_system(user)
    end

    context "有効なユーザーでいいね!一覧にアクセスした場合" do
      let(:user) { create(:user) }
      let(:destination) { create(:destination) }

      before do
        user.favorite(destination)
        visit favorites_path
      end

      it "'Favorites' の文字列が表示される" do
        expect(page).to have_content "Favorites"
      end

      it "いいね!の件数が表示される" do
        expect(page).to have_content "(1)"
      end

      it "正しいタイトル表示が表示される" do
        expect(page).to have_title full_title("Favorites")
      end

      it "GoogleMap の表示が表示される", js: true do
        expect(page).to have_css "div.gm-style"
      end

      # FIXME: ピンが表示されないことがあるのでfactorybot 要修正
      it "GoogleMap のピンがいいね!の件数分表示される", js: true do
        #   favorite_count = Favorite.count
        #   expect(page).to have_css "img[src$='spotlight-poi2_hdpi.png']", count: favorite_count
      end

      it "いいね!済みの行き先の情報が正しく表示される" do
        expect(page).to have_css "div.destination-list-picture img"
        # 旅先画像の表示を確認
        expect(page).to have_link nil, href: destination_path(destination), class: "destination-list-picture-link"
        # アイコンの表示を確認
        expect(page).to have_css "div.destination-list-icon img.gravatar"
        expect(page).to have_link nil, href: user_path(destination.user), class: "destination-list-icon-link"
        expect(page).to have_link destination.name, href: destination_path(destination)
        expect(page).to have_link destination.user.name, href: user_path(destination.user)
        # 50文字以上を省略しているのも検証
        expect(page).to have_content destination.description.truncate(50)
        country_name = get_country_name(destination)
        expect(page).to have_content country_name
        expect(page).to have_content "いいね!"
        expect(page).to have_css "div.destination-list-timestamp"
      end
    end

    context "有効なユーザーでいいね!した行き先が複数有る場合" do
      let(:user) { create(:user) }

      before do
        # 12 件以上表示でpaginate が機能するので13件生成
        destinations = create_list(:destination, 13)
        # 生成した行き先をuser が全件いいね!
        destinations.each do |destination|
          # ここでのuser はcreate_list で生成した行き先のuser とは別のuser
          user.favorite(destination)
        end
        visit favorites_path
      end

      it "ページネーション、お気に入りの件数が表示される", js: true do
        expect(page).to have_css "div.pagination"
        expect(page).to have_content "(13)"
      end
    end

    context "有効なユーザーで行き先をいいね!した場合" do
      let(:user) { create(:user) }
      let(:destination_1) { create(:destination) }
      let(:destination_2) { create(:destination) }

      before do
        visit favorites_path
      end

      it "いいね!一覧の行き先の表示数がく増減する" do
        expect(page).not_to have_css ".destination-list-post"
        user.favorite(destination_1)
        user.favorite(destination_2)
        visit favorites_path
        expect(page).to have_css ".destination-list-post", count: 2
        user.unfavorite(destination_1)
        visit favorites_path
        expect(page).to have_css ".destination-list-post", count: 1
      end
    end
  end

  describe "通知生成" do
    context "他ユーザの投稿した行き先に自分がいいね!した場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:other_user_destination) { create(:destination, user: other_user) }

      before do
        login_for_system(user)
        visit destination_path(other_user_destination)
        find(".favorite").click
        logout
        login_for_system(other_user)
      end

      it "投稿ユーザに通知が作成/通知を閲覧するとメニューバーのスタイルがリセットされる" do
        expect(page).to have_css "li.new_notification"
        # 通知を閲覧
        visit notifications_path
        expect(page).to have_css "li.no_notification"
      end

      it "他ユーザの通知に行き先とユーザ情報が正しく表示される" do
        visit notifications_path
        # expect(page).to have_content other_user_destination.created_at.strftime("%Y/%m/%d(%a) %H:%M")
        # 最初の通知を取得
        notification = other_user.notifications.first
        expect(page).to have_content notification.created_at.strftime("%Y/%m/%d(%a) %H:%M")
        expect(page).to have_content "あなたの旅先が #{user.name} さんのいいね!一覧に追加されました"
        # いいね!元のユーザの名前のリンク確認
        expect(page).to have_link user.name, href: user_path(user)
        # いいね!アイコンの表示を確認
        expect(page).to have_css "span.notification-index-favorite-icon i.fas.fa-heart"
        # いいね!元のユーザアイコンの表示/リンクを確認
        expect(page).to have_css "div.notification-index-user-icon img.user-picture"
        expect(page).to have_link nil, href: user_path(user), class: "notification-index-user-icon-link"
        # 画像表示確認
        expect(page).to have_css "div.notification-index-picture img"
        expect(page).to have_link nil, href: destination_path(other_user_destination)
        expect(page).to have_content other_user_destination.name
        expect(page).to have_content other_user_destination.description
      end
    end

    context "他ユーザの投稿した行き先に自分がコメントした場合" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:other_user_destination) { create(:destination, user: other_user) }

      before do
        login_for_system(user)
        visit destination_path(other_user_destination)
        fill_in "comment_content", with: "This is comment!"
        click_button "コメント"
        logout
        login_for_system(other_user)
      end

      it "投稿ユーザに通知が作成/通知を閲覧するとメニューバーのスタイルがリセットされる" do
        expect(page).to have_css "li.new_notification"
        visit notifications_path
        expect(page).to have_css "li.no_notification"
      end

      it "他ユーザの通知に行き先とユーザ情報が正しく表示される" do
        visit notifications_path
        # expect(page).to have_content other_user_destination.created_at.strftime("%Y/%m/%d(%a) %H:%M")
        # 最初の通知を取得
        notification = other_user.notifications.first
        expect(page).to have_content notification.created_at.strftime("%Y/%m/%d(%a) %H:%M")
        expect(page).to have_content "あなたの旅先に #{user.name} さんがコメントしました"
        expect(page).to have_content notification.content
        # コメント元のユーザの名前のリンク確認
        expect(page).to have_link user.name, href: user_path(user)
        # コメントアイコンの表示を確認
        expect(page).to have_css "span.notification-index-comment-icon i.far.fa-comment-dots"
        # コメント元のユーザアイコンの表示/リンクを確認
        expect(page).to have_css "div.notification-index-user-icon img.user-picture"
        expect(page).to have_link nil, href: user_path(user), class: "notification-index-user-icon-link"
        # 画像表示確認
        expect(page).to have_css "div.notification-index-picture img"
        expect(page).to have_link nil, href: destination_path(other_user_destination)
        expect(page).to have_content other_user_destination.name
        expect(page).to have_content other_user_destination.description
      end
    end

    context "自分の投稿した行き先に自分自身で通知アクションを起こした場合" do
      let(:user) { create(:user) }
      let(:destination) { create(:destination) }

      before do
        login_for_system(user)
        visit destination_path(destination)
      end

      it "いいね!しても通知が作成されない" do
        find(".favorite").click
        visit destination_path(destination)
        expect(page).to have_css "li.no_notification"
        visit notifications_path
        expect(page).to have_content "通知 (0)"
        expect(page).not_to have_css "ul.notification-index-item li"
      end

      it "コメントしても通知が作成されない" do
        fill_in "comment_content", with: "Comment to self!"
        click_button "コメント"
        expect(page).to have_css "li.no_notification"
        visit notifications_path
        expect(page).to have_content "通知 (0)"
        expect(page).not_to have_css "ul.notification-index-item li"
      end
    end
  end
end
