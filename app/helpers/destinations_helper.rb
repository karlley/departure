module DestinationsHelper
  # destinations#edit で画像登録済みでtrue を返す
  def edit_page_and_have_picture?
    @destination.id.present? && @destination.picture.url.present?
  end

  # destinations#edit でedit ページでtrue を返す
  def edit_page?
    @destination.id.present?
  end

  # 国番号から国名を取得
  def get_country_name(destination)
    Country.find_by(id: destination.country).country_name
  end
end
