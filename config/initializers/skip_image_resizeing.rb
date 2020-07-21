# テスト環境で画像リサイズ処理を無効化
if Rails.env.test?
  CarrierWave.configure do |config|
    config.enable_processing = false
  end
end
