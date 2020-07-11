require 'rails_helper'

RSpec.describe "Destination ページ", type: :request do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  context "許可されたユーザーの場合" do
    it "レスポンスが正常に表示されること" do
      login_for_request(user)
      get destination_path(destination)
      expect(response).to have_http_status "200"
      expect(response).to render_template('destinations/show')
    end
  end

  context "ログインされていないユーザーの場合" do
    it "ログイン画面にリダイレクトすること" do
      get destination_path(destination)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end
end
