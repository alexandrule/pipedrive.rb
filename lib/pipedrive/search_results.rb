module Pipedrive
  class SearchResult < Base
    def search(params = {})
      make_api_call(:get, params.merge(entity_hard_path: 'searchResults'))
    end

    def field(params = {})
      make_api_call(:get, params.merge(entity_hard_path: 'searchResults/field'))
    end
  end
end
