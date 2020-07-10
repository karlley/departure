require 'rails_helper'

RSpec.describe "New Destinations", type: :request do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  context "ログインしているユーザーの場合" do
    before do
      login_for_request(user)
      get new_destination_path
    end

    it "レスポンスが正常に表示される" do
      expect(response).to have_http_status "200"
      expect(response).to render_template('destinations/new')
    end

    it "有効な行き先データで登録できる" do
      expect do
        post destinations_path, params: { destination: {
          name: "行き先のサンプル",
          description: "行き先のサンプルの説明",
          country: "日本",
        } }
      end.to change(Destination, :count).by(1)
      follow_redirect!
      expect(response).to render_template('static_pages/home')
    end

    it "無効な行き先データで登録できない" do
      expect do
        post destinations_path, params: { destination: {
          name: "",
          description: "行き先のサンプルの説明",
          country: "日本",
        } }
      end.not_to change(Destination, :count)
      expect(response).to render_template('destinations/new')
    end
  end

  context "ログインしていないユーザーの場合" do
    it "ログイン画面にリダイレクトする" do
      get new_destination_path
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end
end
