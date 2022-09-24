# frozen_string_literal: true

require_relative "zoho_subscriptions_kit/version"
require_relative 'zoho_subscriptions_kit/client'

module ZohoSubscriptionsKit
  class << self
    def client
      @client ||= ZohoSubscriptionsKit::Client.new
    end

    def enable_debug_excon!
      @debug_excon_enabled = true
    end

    def disable_debug_excon!
      @debug_excon_enabled = false
    end

    def debug_excon_enabled?
      !!@debug_excon_enabled
    end

    def method_missing(method_name, *args, &block)
      if client.respond_to?(method_name)
        return client.send(method_name, *args, &block)
      end

      super
    end
  end
end
