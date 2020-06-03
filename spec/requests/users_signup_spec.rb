require 'rails_helper'

RSpec.describe "Signup", type: :request do
  before do
    get signup_path
  end

  it "正常なレスポンスを返すこと" do
    expect(response).to be_successful
    expect(response).to have_http_status "200"
  end
end
