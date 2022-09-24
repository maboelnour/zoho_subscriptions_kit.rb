# frozen_string_literal: true

module ZohoSubscriptionsKit
  class Client
    module Subscriptions
      def subscriptions
        get "subscriptions"
      end
      def new_subscription(data:)
        post "subscriptions", data
      end
    end
  end
end