module DestinationsHelper
  # edit ページが表示されていればtrue を返す
  def edit_page?
    @destination.id.present?
  end

  # 画像が登録されているばtrue を返す
  def have_picture?
    @destination.picture.url.present?
  end
end
