module DestinationsHelper
  # edit ページが表示されていればtrue を返す
  def edit_page?
    @destination.id.present?
  end

  # 画像が登録されているばtrue を返す
  def have_picture?
    @destination.picture.url.present?
  end

  # 国番号から国名を取得
  def get_country_name(destination)
    Country.find_by(id: destination.country).country_name
  end
end
