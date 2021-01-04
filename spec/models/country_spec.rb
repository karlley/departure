require 'rails_helper'

RSpec.describe Country, type: :model do
  let!(:country) { create(:country) }

  context "バリデーション" do
    it "有効な状態であること" do
      expect(country).to be_valid
    end

    it "country_name が無い場合は無効な状態であること" do
      country = build(:country, country_name: nil)
      expect(country).not_to be_valid
    end

    it "region が無い場合は無効な状態で有ること" do
      country = build(:country, region: nil)
      expect(country).not_to be_valid
    end
  end
end
