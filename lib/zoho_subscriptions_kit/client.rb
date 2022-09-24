# frozen_string_literal: true

require_relative 'client/connection'
require_relative 'client/subscriptions'
require_relative 'client/hosted_pages'
require_relative 'client/customers'

module ZohoSubscriptionsKit
  class Client
    include ZohoSubscriptionsKit::Client::Connection
    include ZohoSubscriptionsKit::Client::Subscriptions
    include ZohoSubscriptionsKit::Client::HostedPages
    include ZohoSubscriptionsKit::Client::Customers

  end
end
