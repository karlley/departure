require "rails_helper"

RSpec.describe "Profile ページ", type: :request do
  let!(:user) { create(:user) }

  it "レスポンスが正常に表示される" do
    login_for_request(user)
    get user_path(user)
    expect(response).to render_template('users/show')
  end
end
