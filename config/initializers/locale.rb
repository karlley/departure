# locals ファイル読込ディレクトリ
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

# デフォルト言語
I18n.default_locale = :ja

# アプリケーションで有効化する言語指定
I18n.available_locales = :ja
