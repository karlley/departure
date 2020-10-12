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

    it "ユーザーID が未入力で無効な状態であること" do
      destination = build(:destination, user_id: nil)
      destination.valid?
      expect(destination.errors[:user_id]).to include("を入力してください")
    end

    it "名前が未入力で無効な状態であること" do
      destination = build(:destination, name: nil)
      destination.valid?
      expect(destination.errors[:name]).to include("を入力してください")
    end

    it "名前が50字以内であること" do
      destination = build(:destination, name: "a" * 51)
      destination.valid?
      expect(destination.errors[:name]).to include("は50文字以内で入力してください")
    end

    it "国名が未入力で無効な状態であること" do
      destination = build(:destination, country: nil)
      destination.valid?
      expect(destination.errors[:country]).to include("を入力してください")
    end

    it "国名が100字以内であること" do
      destination = build(:destination, country: "a" * 101)
      destination.valid?
      expect(destination.errors[:country]).to include("は100文字以内で入力してください")
    end

    it "説明が任意入力になっていること" do
      destination = build(:destination, description: nil)
      expect(destination).to be_valid
    end

    it "説明が140字以内であること" do
      destination = build(:destination, description: "a" * 141)
      destination.valid?
      expect(destination.errors[:description]).to include("は140文字以内で入力してください")
    end

    it "スポットが任意入力になっていること" do
      destination = build(:destination, spot: nil)
      expect(destination).to be_valid
    end

    it "スポットが100文字以内であること" do
      destination = build(:destination, spot: "a" * 101)
      destination.valid?
      expect(destination.errors[:spot]).to include("は100文字以内で入力してください")
    end

    it "address が100字以上だと無効であること" do
      destination = build(:destination, address: "a" * 101)
      expect(destination).not_to be_valid
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

  context "address_keyword メソッド" do
    it "geocoder で使用する文字列を生成できること" do
      destination = build(:destination, name: "name", country: "country", spot: "spot")
      keyword = destination.address_keyword
      expect(keyword).to eq "name, country, spot"
    end
  end

  context "add_address メソッド" do
    it "address カラムに住所を追加できること" do
      destination = build(:destination, latitude: 35.658584, longitude: 139.7454316, address: nil)
      destination.add_address
      expect(destination.address).to eq "日本、〒105-0011 東京都港区芝公園４丁目２−８"
      expect(destination).to be_valid
    end
  end

  context "update_address メソッド" do
    it "座標の更新があった場合にaddress カラムを更新できること" do
      destination.update(latitude: 35.658584, longitude: 139.7454316)
      destination.update_address
      expect(destination.address).to eq "日本、〒105-0011 東京都港区芝公園４丁目２−８"
    end

    it "座標の更新が無い場合はメソッドをパスすること" do
      destination.update(name: "edit name", spot: "edit spot", country: "edit country")
      destination.update_address
      expect(destination.update_address).to eq nil
    end
  end

  context "geocoder 機能" do
    it "経度, 緯度が取得できること" do
      destination = build(:destination, name: "東京", country: "日本", spot: "東京タワー", latitude: nil, longitude: nil)
      destination.geocode
      #be_within である程度のゆらぎを許容する
      expect(destination.latitude).to be_within(0.0005).of 35.658584
      expect(destination.longitude).to be_within(0.0005).of 139.7454316
    end
  end
end
