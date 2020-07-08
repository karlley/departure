require 'rails_helper'

RSpec.describe "New Destinations", type: :request do
  let!(:user) { create(:user) }
  let!(:destination) { create(:destination, user: user) }

  context "ログインしているユーザーの場合" do
    it "レスポンスが正常に表示される" do
      login_for_request(user)
      get new_destination_path
      expect(response).to have_http_status "200"
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
