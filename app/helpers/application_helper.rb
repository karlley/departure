module ApplicationHelper
  def full_title(page_title = '')
    base_title = 'Departure'
    if page_title.blank?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end

  # TODO: 条件検索用に修正する
  # 検索ワードが入力されて検索されたらtrue を返す
  def search_query?
    params[:q] != nil
    # params[:q][:name_or_spot_or_address_cont] != nil
  end

  # 条件検索が入力されて検索されたらtrue を返す
  def search_condition?
    !params[:q][:country_eq].nil? || !params[:q][:expense_eq].nil? || params[:q][:season_eq]
  end
end
