require 'rails_helper'

RSpec.describe Notification, type: :model do
  let!(:notification) { create(:notification) }

  it "notification インスタンスが有効であること" do
    expect(notification).to be_valid
  end

  it "user_id がnil の場合, 無効であること" do
    notification.user_id = nil
    expect(notification).not_to be_valid
  end

  it "destination_id がnil の場合, 無効であること" do
    notification.destination_id = nil
    expect(notification).not_to be_valid
  end

  it "from_user_id がnil の場合, 無効であること" do
    notification.from_user_id = nil
    expect(notification).not_to be_valid
  end

  it "type がnil の場合, 無効であること" do
    notification.type = nil
    expect(notification).not_to be_valid
  end
end
