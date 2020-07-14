require 'rails_helper'

RSpec.describe "Edit Destination ページ", type: :request do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  context "認可されたユーザーの場合" do
    it "レスポンスが正常に表示されること(+フレンドリーフォロワーディング)" do
      get edit_destination_path(destination)
      login_for_request(user)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to edit_destination_url(destination)
      patch destination_path(destination), params: { destination: {
        name: "sample destination",
        description: "sample description",
        country: "Japan",
      } }
      redirect_to destination
      follow_redirect!
      expect(response).to render_template('destinations/show')
    end
  end

  context "ログインしていないユーザーの場合" do
    it "ログイン画面にリダイレクトすること" do
      get edit_destination_path(destination)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
      patch destination_path(destination), params: { destination: {
        name: "sample destination",
        description: "sample description",
        country: "Japan",
      } }
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end
end