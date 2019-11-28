module Pipedrive
  class Person < Base
    include ::Pipedrive::Operations::Read
    include ::Pipedrive::Operations::Create
    include ::Pipedrive::Operations::Update
    include ::Pipedrive::Operations::Delete
    include ::Pipedrive::Utils

    def find_by_name(*args)
      params = args.extract_options!
      params[:term] ||= args[0]
      fail 'term is missing' unless params[:term]
      params[:search_by_email] ||= args[1] ? 1 : 0
      return to_enum(:find_by_name, params) unless block_given?
      follow_pagination(:make_api_call, [:get, 'find'], params) { |item| yield item }
    end

    def deals(*args)
      params = args.extract_options!
      id = params.delete(:id)
      make_api_call(:get, params.merge(entity_hard_path: "persons/#{id}/deals"))
    end
  end
end
