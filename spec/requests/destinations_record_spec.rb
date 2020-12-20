require 'rails_helper'

RSpec.describe "New Destinations", type: :request do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }
  let(:picture_path_1) { File.join(Rails.root, "spec/fixtures/test_destination_1.jpg") }
  let(:picture_1) { Rack::Test::UploadedFile.new(picture_path_1) }

  context "ログインしているユーザーの場合" do
    before do
      get new_destination_path
      login_for_request(user)
    end

    it "レスポンスが正常に表示される(+フレンドリーフォロワーディング)" do
      expect(response).to have_http_status "302"
      expect(response).to redirect_to new_destination_url
    end

    it "有効な行き先データで登録できる" do
      expect do
        post destinations_path, params: { destination: {
          name: "行き先のサンプル",
          description: "行き先のサンプルの説明",
          country: 1,
          expense: 1,
          season: 1,
          picture: picture_1,
        } }
      end.to change(Destination, :count).by(1)
      follow_redirect!
      expect(response).to render_template('destinations/show')
    end

    it "無効な行き先データで登録できない" do
      expect do
        post destinations_path, params: { destination: {
          name: "",
          description: "行き先のサンプルの説明",
          country: "日本",
          picture: picture_1,
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
