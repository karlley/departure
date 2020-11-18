# 開発環境別にseeds ファイルを読み込む設定
load(Rails.root.join("db", "seeds", "#{Rails.env.downcase}.rb"))
