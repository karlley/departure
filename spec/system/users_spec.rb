require 'rails_helper'

RSpec.describe "Users", type: :system do
  describe "Users", type: :system do
    before do
      visit signup_path
    end

    context "ページレイアウト" do
      it "Signup の文字列の存在を確認" do
        expect(page).to have_content 'Signup'
      end

      it "正しいタイトル表示を確認" do
        expect(page).to have_title full_title('Signup')
      end
    end
  end
end
