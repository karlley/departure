require 'rails_helper'

RSpec.describe "Edit Destination ページ", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:destination) { create(:destination, user: user) }
  let(:picture_path_2) { File.join(Rails.root, "spec/fixtures/test_destination_2.jpg") }
  let!(:picture_2) { Rack::Test::UploadedFile.new(picture_path_2) }

  context "認可されたユーザーの場合" do
    it "レスポンスが正常に表示されること(+フレンドリーフォロワーディング)" do
      get edit_destination_path(destination)
      login_for_request(user)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to edit_destination_url(destination)
      patch destination_path(destination), params: { destination: {
        name: "sample destination",
        description: "sample description",
        country_id: 10,
        expense: "till_50000",
        picture: picture_2,
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
        country_id: 10,
        expense: "till_50000",
        picture: picture_2,
      } }
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end

  context "別アカウントのユーザーの場合" do
    it "ホーム画面へリダイレクトすること" do
      login_for_request(other_user)
      get edit_destination_path(destination)
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
      patch destination_path(destination), params: { destination: {
        name: "sample destination",
        description: "sample description",
        country_id: 10,
        expense: "till_50000",
        picture: picture_2,
      } }
      expect(response).to have_http_status "302"
      expect(response).to redirect_to root_path
    end
  end
end
