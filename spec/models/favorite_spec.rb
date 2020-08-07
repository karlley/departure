require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let!(:favorite) { create(:favorite) }

  context "バリデーション" do
    it "有効な状態であること" do
      expect(favorite).to be_valid
    end

    it "user_id がnil の場合は無効であること" do
      favorite.user_id = nil
      expect(favorite).not_to be_valid
    end

    it "destination_id がnil の場合は無効であること" do
      favorite.destination_id = nil
      expect(favorite).not_to be_valid
    end
  end
end
