# frozen_string_literal: true

module ZohoSubscriptionsKit
  class Client
    module Customers
      def customers(query={})
        get "customers", query
      end
    end
  end
end