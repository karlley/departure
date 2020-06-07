require 'rails_helper'

RSpec.describe "Signup ページ", type: :request do
  before do
    get signup_path
  end

  it "正常なレスポンスを返すこと" do
    expect(response).to be_successful
    expect(response).to have_http_status "200"
  end

  it "有効なユーザーで登録" do
    expect do
      post users_path, params: { user: {
        name: "Example User",
        email: "user@example.com",
        password: "password",
        password_confirmation: "password",
      } }
    end.to change(User, :count).by(1)
    redirect_to @user
    follow_redirect!
    expect(response). to render_template('users/show')
  end

  it "無効なユーザーで登録" do
    expect do
      post users_path, params: { user: {
        name: "",
        email: "user@example.com",
        password: "password",
        password_confirmation: "pass",
      } }
    end.not_to change(User, :count)
  end
end
