# frozen_string_literal: true

module ZohoSubscriptionsKit
  class Client
    module Connection
      MAX_REFRESH_RETRY_COUNT = 1

      def get(path, query={})
        request(method: :get, path: path, query: query)
      end

      def put(path, data)
        request(method: :put, path: path, data: data)
      end

      def post(path, data)
        request(method: :post, path: path, data: data)
      end

      private

      def request(method:, path:, data: {}, query: {}, refresh_retry_count: 0)
        opts = {
          headers: headers,
          body: data.to_json,
          query: query
        }
        opts[:instrumentor] = ActiveSupport::Notifications if ZohoSubscriptionsKit.debug_excon_enabled?
        response = Excon.send(method, [base_url, path].join("/"), opts)
        if response.status.to_i >= 200 && response.status.to_i < 300
          body = JSON.parse(response.body, object_class: OpenStruct)
          raise "Zoho subscription API Error, response.status: #{response.status}, code: #{body.code}, message: #{body.message}" if body.code != 0
          return body
        elsif response.status == 401
          if refresh_retry_count < MAX_REFRESH_RETRY_COUNT
            refresh_access_token
            return request(method: method, path: path, data: data, query: query, refresh_retry_count: refresh_retry_count+1)
          else
            raise "Failed to regenerate an access token and reached MAX_REFRESH_RETRY_COUNT"
          end
        else
          raise "Error while calling Zoho subscription API, response.status: #{response.status}, response.body: #{response.body}"
        end
      end

      def base_url
        @base_url ||= "https://subscriptions.zoho.com/api/v1"
      end

      def headers
        {
          'X-com-zoho-subscriptions-organizationid' => ENV['ZOHO_ORGANIZATION_ID'],
          'Content-Type' => 'application/json;charset=UTF-8',
          'Authorization' => "Zoho-oauthtoken #{zoho_oauth_token.access_token}"
        }
      end

      def zoho_oauth_token
        ZohoApiTokenMaindbPersistor.new.get_oauth_tokens(ENV['ZOHO_API_USER_EMAIL'])
      end

      def refresh_access_token
        Rails.logger.info "Refreshing Zoho API access token"
        opts = {
          headers: refresh_headers,
          body: refresh_data
        }
        opts[:instrumentor] = ActiveSupport::Notifications if ZohoSubscriptionsKit.debug_excon_enabled?
        response = Excon.post(refresh_base_url, opts)

        body = JSON.parse(response.body, object_class: OpenStruct)
        raise "Error while refreshing Zoho subscriptions access token: Got nil access token while refreshing" unless body.access_token

        expiry_time = DateTime.now.strftime('%Q').to_i + (body.expires_in.to_i*1000) # to save expiry_time in milli
        ZohoApiTokenMaindbPersistor.new.update_access_token(
          ENV['ZOHO_API_USER_EMAIL'],
          body.access_token,
          expiry_time
        )
      end

      def refresh_base_url
        @refresh_base_url ||= "https://accounts.zoho.com/oauth/v2/token"
      end

      def refresh_headers
        {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      end

      def refresh_token
        @refresh_token ||= zoho_oauth_token.refresh_token
      end

      def refresh_data
        [
          "refresh_token=#{refresh_token}",
          "client_id=#{ENV['ZOHO_API_CLIENT_ID']}",
          "client_secret=#{ENV['ZOHO_API_CLIENT_SECRET']}",
          "grant_type=refresh_token"
        ].join("&")
      end
    end
  end
end
