require 'rails_helper'

RSpec.describe "Login ページ", type: :request do
  let!(:user) { create(:user) }

  it "正常なレスポンスを返すこと" do
    get login_path
    expect(response).to be_successful
    expect(response).to have_http_status "200"
  end
end
