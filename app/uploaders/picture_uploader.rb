class PictureUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # production, develop 環境ではクラウドストレージに画像を保存する
  if Rails.env.production?
    storage :fog
  elsif Rails.env.development?
    storage :fog
  else
    storage :file
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # development時とtest時で画像が保存されるディレクトリを分ける
  def store_dir
    if Rails.env.test?
      "uploads_#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    else
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

  # 画像未設定時のデフォルトの画像のURL
  def default_url(*args)
    "/images/" + [version_name, "default.png"].compact.join('_')
  end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # 画像サイズ
  # show用 400*400, 正方形に整形
  version :thumb400 do
    process resize_and_pad(400, 400, background = :transparent, gravity = "Center")
  end

  # index用 200*200, 正方形に切り抜き
  version :thumb200 do
    process resize_to_fill: [200, 200, "Center"]
  end

  # 拡張子gif を削除
  def extension_whitelist
    %w(jpg jpeg png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
