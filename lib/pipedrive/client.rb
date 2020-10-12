module Pipedrive
  class Client
    require 'oauth2'

    OAUTH_ENDPOINT = 'https://oauth.pipedrive.com/oauth/token'

    attr_reader :endpoint, :access_token, :redirect_uri, :client_id,
                :client_secret, :scope, :state

    def initialize(attrs = {})
      @endpoint = attrs[:endpoint]
      @access_token = attrs[:access_token]
      @client_id = attrs[:client_id]
      @client_secret = attrs[:client_secret]
      @redirect_uri = attrs[:redirect_uri]
      @state = attrs[:state]
    end

    def oauth2client
      @_oauth2client ||=
        OAuth2::Client.new(
          client_id,
          client_secret,
          site: OAUTH_ENDPOINT
        )
    end

    def authorize_url
      return unless oauth2client

      attrs = { redirect_uri: redirect_uri }
      attrs[:state] = state if state

      oauth2client.auth_code.authorize_url(attrs)
    end

    def fetch_access_token(code)
      return unless oauth2client

      token = oauth2client.auth_code.get_token(code, redirect_uri: redirect_uri)
      token.params.merge(
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_at: token.expires_at,
        expires_in: token.expires_in
      )
    rescue OAuth2::Error => e
      puts e if ::Pipedrive.debug
    end

    def fetch_refresh_token(refresh_token)
      return unless oauth2client

      token = oauth2client.get_token(
        refresh_token: refresh_token,
        grant_type: 'refresh_token'
      )
      token.params.merge(
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_at: token.expires_at
      )
    rescue OAuth2::Error => e
      puts e if ::Pipedrive.debug
      e.message
    end

    private

    def basic_auth_string
      Base64.encode64("#{client_id}:#{client_secret}")
    end
  end
end
