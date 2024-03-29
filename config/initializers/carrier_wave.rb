  CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      # AWS S3 に環境変数を読込
      :provider              => 'AWS',
      :region                => ENV['S3_REGION'],
      :aws_access_key_id     => ENV['S3_ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
    }
    config.fog_directory     =  ENV['S3_BUCKET']
  end
