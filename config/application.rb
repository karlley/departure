require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Departure
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # JS, CSS, minitest  generate false
    config.generators do |g|
      g.assets false
      g.test_framework :rspec,
        controller_specs: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
    end

    # 認証トークンをremote フォームに埋め込む
    config.action_view.embed_authenticity_token_in_remote_forms = true

    # timezone 修正
    config.time_zone = "Tokyo"

    # iTerm2 にRSpec のスクリーンショットを表示する為の環境変数
    ENV["RAILS_SYSTEM_TESTING_SCREENSHOT"] = "inline"
  end
end
