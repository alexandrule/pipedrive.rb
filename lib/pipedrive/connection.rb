module Pipedrive
  class Connection
    API_ENDPOINT = 'https://api-proxy.pipedrive.com'.freeze
    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
    end

    def faraday_options
      {
        url: API_ENDPOINT,
        headers: {
          accept: 'application/json',
          user_agent: ::Pipedrive.user_agent,
          authorization: "Bearer #{access_token}"
        }
      }
    end

    def setup(access_token = nil) # :nodoc
      @connection ||= Faraday.new(faraday_options) do |conn|
        conn.request :url_encoded
        conn.response :mashify
        conn.response :json, content_type: /\bjson$/
        conn.use FaradayMiddleware::ParseJson
        conn.response :logger, ::Pipedrive.logger if ::Pipedrive.debug
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
