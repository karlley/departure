require 'rails_helper'

RSpec.describe Airline, type: :model do
  let!(:airline) { create(:airline) }

  context "バリデーション" do
    it "有効な状態であること" do
      expect(airline).to be_valid
    end

    it "airline_name が無いと無効であること" do
      airline = build(:airline, airline_name: nil)
      expect(airline).not_to be_valid
    end

    it "country_id が無いと無効であること" do
      airline = build(:airline, country_id: nil)
      expect(airline).not_to be_valid
    end

    it "alliance が無いと無効であること" do
      airline = build(:airline, alliance: nil)
      expect(airline).not_to be_valid
    end

    it "alliance_type が無いと無効であること" do
      airline = build(:airline, alliance_type: nil)
      expect(airline).not_to be_valid
    end
  end
end
