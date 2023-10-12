# frozen_string_literal: true

module ShopifyApp
  class WebhooksManagerJob < ActiveJob::Base
    queue_as do
      ShopifyApp.configuration.webhooks_manager_queue_name
    end

    def perform(shop_domain:, shop_token:, **)
      ShopifyAPI::Auth::Session.temp(shop: shop_domain, access_token: shop_token) do |session|
        WebhooksManager.create_webhooks(session: session)
      end
    rescue ShopifyAPI::Errors::HttpResponseError => error
      raise error unless error.code == 401
    end
  end
end
