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

    it "国名が未選択で無効な状態であること" do
      destination = build(:destination, country_id: nil)
      destination.valid?
      expect(destination.errors[:country_id]).to include("を入力してください")
    end

    it "費用が未選択で無効な状態であること" do
      destination = build(:destination, expense: nil)
      destination.valid?
      expect(destination.errors[:expense]).to include("は一覧にありません")
    end

    it "シーズンが未選択で無効な状態であること" do
      destination = build(:destination, season: nil)
      destination.valid?
      expect(destination.errors[:season]).to include("を入力してください")
    end

    it "体験が50文字以内であること" do
      destination = build(:destination, experience: "a" * 51)
      destination.valid?
      expect(destination.errors[:experience]).to include("は50文字以内で入力してください")
    end

    it "食べ物が50文字以内であること" do
      destination = build(:destination, food: "a" * 51)
      destination.valid?
      expect(destination.errors[:food]).to include("は50文字以内で入力してください")
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
      destination = build(:destination, name: "行き先名", country_id: 162, spot: "スポット")
      keyword = destination.address_keyword
      expect(keyword).to eq "行き先名, 日本, スポット"
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
      destination = create(:destination)
      destination.latitude = 35.658584
      destination.longitude = 139.7454316
      destination.update_address
      expect(destination.address).to eq "日本、〒105-0011 東京都港区芝公園４丁目２−８"
    end

    it "座標の更新が無い場合はメソッドをパスすること" do
      destination = create(:destination)
      destination.update_address
      # 住所が更新されていない事を確認
      expect(destination.address).to eq destination.address
    end
  end

  context "geocoder 機能" do
    it "経度, 緯度が取得できること" do
      destination = build(:destination, name: "東京", country_id: 153, spot: "東京タワー", latitude: nil, longitude: nil)
      destination.geocode
      # be_within である程度のゆらぎを許容する
      expect(destination.latitude).to be_within(0.0005).of 35.658584
      expect(destination.longitude).to be_within(0.0005).of 139.7454316
    end
  end
end
