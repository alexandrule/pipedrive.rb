module Pipedrive
  class Base
    attr_reader :api_token

    def initialize(api_token = ::Pipedrive.api_token)
      fail 'api_token should be set' unless api_token.present?
      @api_token = api_token
    end

    def connection
      @_connection ||= Connection.new(api_token).setup
    end

    def make_api_call(*args)
      params = args.extract_options!
      method = args[0]
      fail 'method param missing' unless method.present?
      url = build_url(
        args,
        fields_to_select: params.delete(:fields_to_select),
        entity_hard_path: params.delete(:entity_hard_path)
      )
      begin
        res = connection.__send__(method.to_sym, url, params)
      rescue Errno::ETIMEDOUT
        retry
      rescue Faraday::ParsingError
        sleep 5
        retry
      end
      process_response(res)
    end

    def build_url(args, options = {})
      fields_to_select = options.fetch(:fields_to_select) { nil }
      entity_path = options[:entity_hard_path] || entity_name
      url = "/#{entity_path}"
      url << "/#{args[1]}" if args[1]
      if fields_to_select.is_a?(::Array) && fields_to_select.size > 0
        url << ":(#{fields_to_select.join(',')})"
      end
      url
    end

    def process_response(res)
      if res.success?
        data = if res.body.is_a?(::Hashie::Mash)
                 res.body.merge(success: true)
               else
                 ::Hashie::Mash.new(success: true)
               end
        return data
      end
      failed_response(res)
    end

    def failed_response(res)
      failed_res = res.body.merge(success: false, not_authorized: false,
                                  failed: false)
      case res.status
      when 401
        failed_res.merge! not_authorized: true
      when 420
        failed_res.merge! failed: true
      end
      failed_res
    end

    def entity_name
      self.class.name.split('::')[-1].downcase.pluralize
    end
  end
end
