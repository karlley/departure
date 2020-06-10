require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  let!(:user) { create(:user) }

  before do
    visit login_path
  end

  describe "Login ページ" do
    context "ページレイアウト" do
      it "Login の文字列の存在を確認" do
        expect(page).to have_content "Login"
      end

      it "正しいタイトル表示を確認" do
        expect(page).to have_title full_title('Login')
      end

      it "ログインフォームのラベルが正しく表示される" do
        expect(page).to have_content 'メールアドレス'
        expect(page).to have_content 'パスワード'
      end

      it "ログインフォームが正しく表示される" do
        expect(page).to have_css 'input#user_email'
        expect(page).to have_css 'input#user_password'
      end

      it "ログインボタン が表示される" do
        expect(page).to have_button 'ログイン'
      end
    end
  end
end
