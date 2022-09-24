# frozen_string_literal: true

module ZohoSubscriptionsKit
  class Client
    module HostedPages
      def hostedpages
        get "hostedpages"
      end

      def hostedpages_newsubscription(data:)
        post "hostedpages/newsubscription", data
      end

      def hostedpages_updatecard(data:)
        post "hostedpages/updatecard", data
      end
    end
  end
end  