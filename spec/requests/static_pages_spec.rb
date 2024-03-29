require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "Home ページ" do
    it "正常なレスポンスを返す" do
      get root_path
      expect(response).to be_successful
      expect(response).to have_http_status "200"
    end
  end

  describe "About ページ" do
    it "正常なレスポンスを返す" do
      get about_path
      expect(response).to be_successful
      expect(response).to have_http_status "200"
    end
  end
end
