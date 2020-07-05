require 'rails_helper'

RSpec.describe Destination, type: :model do
  let!(:destination_yesterday) { create(:destination, :yesterday) }
  let!(:destination_one_week_ago) { create(:destination, :one_week_ago) }
  let!(:destination_one_month_ago) { create(:destination, :one_month_ago) }
  let!(:destination) { create(:destination) }

  context "バリデーション" do
    it "有効な状態であること" do
      expect(destination).to be_valid
    end

    it "名前がなければ無効な状態であること" do
      destination = build(:destination, name: nil)
      destination.valid?
      expect(destination.errors[:name]).to include("を入力してください")
    end

    it "名前が50字以内であること" do
      destination = build(:destination, name: "a" * 51)
      destination.valid?
      expect(destination.errors[:name]).to include("は50文字以内で入力してください")
    end

    it "国名がなければ無効な状態であること" do
      destination = build(:destination, country: nil)
      destination.valid?
      expect(destination.errors[:country]).to include("を入力してください")
    end

    it "国名が50字以内であること" do
      destination = build(:destination, country: "a" * 51)
      destination.valid?
      expect(destination.errors[:country]).to include("は50文字以内で入力してください")
    end

    it "説明が140字以内であること" do
      destination = build(:destination, description: "a" * 141)
      destination.valid?
      expect(destination.errors[:description]).to include("は140文字以内で入力してください")
    end
  end

  context "並び順" do
    it "最新の投稿が最初の投稿になっていること" do
      expect(destination).to eq Destination.first
    end

    it "最古の投稿が最後の投稿になっていること" do
      expect(destination_one_month_ago).to eq Destination.last
    end
  end
end
