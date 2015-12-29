require "values"
require "gemonames/web_services"

module Gemonames
  class ApiClient
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def search(query, country_code:, limit: 10)
      perform_search :search,
        query: query, country: country_code, maxRows: limit
    end

    def find(query, **args)
      one_result(search(query, **args.merge(limit: 1)))
    end

    def reverse_search(latitude:, longitude:, limit: 10)
      perform_search :find_nearby_place_name,
        lat: latitude, lng: longitude, maxRows: limit
    end

    def reverse_find(**args)
      one_result(reverse_search(**args.merge(limit: 1)))
    end

    private

    def perform_search(endpoint, **args)
      extract_payload(
        WebServices.public_send(endpoint, connection, **args)
      )
    end

    def one_result(results)
      results.first || SearchResult.with(
        geoname_id: nil,
        name: nil,
        country_code: nil,
        admin_id4: nil,
        admin_id3: nil,
        admin_id2: nil,
        admin_id1: nil,
        country_id: nil,
        result: false
      )
    end

    def extract_payload(response)
      response.body
        .fetch("geonames")
        .lazy
        .map { |result| wrap_in_search_result(result) }
    end

    def wrap_in_search_result(result)
      SearchResult.with(
        geoname_id: result.fetch("geonameId".freeze),
        name: result.fetch("name".freeze),
        country_code: result.fetch("countryCode".freeze),
        admin_id4: result["adminId4".freeze],
        admin_id3: result["adminId3".freeze],
        admin_id2: result["adminId2".freeze],
        admin_id1: result["adminId1".freeze],
        country_id: result["countryId".freeze],
        result: true
      )
    end
  end

  SearchResult = Value.new(
    :geoname_id,
    :name,
    :country_code,
    :admin_id4,
    :admin_id3,
    :admin_id2,
    :admin_id1,
    :country_id,
    :result,
  ) do
    alias_method :result?, :result
    alias_method :present?, :result
  end
end
