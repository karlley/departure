module ApplicationHelper
  def full_title(page_title = '')
    base_title = 'Departure'
    if page_title.blank?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end

  # 検索ワードが入力されて検索されたらtrue を返す
  def have_search_word?
    params[:q] != nil
  end
end
