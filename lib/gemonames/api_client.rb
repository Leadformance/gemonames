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

    def find(query, country_code:)
      perform_find :search,
        query: query, country: country_code
    end

    def reverse_search(latitude:, longitude:, limit: 10)
      perform_search :find_nearby_place_name,
        lat: latitude, lng: longitude, maxRows: limit
    end

    def reverse_find(latitude:, longitude:)
      perform_find :find_nearby_place_name,
        lat: latitude, lng: longitude
    end

    private

    def perform_search(endpoint, **args)
      results = extract_payload(
        WebServices.public_send(endpoint, connection, **args)
      )

      results.map { |result|
        wrap_in_search_result(result)
      }
    end

    def perform_find(endpoint, **args)
      args = args.merge(maxRows: 1)

      results = extract_payload(
        WebServices.public_send(endpoint, connection, **args)
      )

      if results.any?
        wrap_in_search_result(results.first)
      else
        NoResultFound.new
      end
    end

    def extract_payload(results)
      results.body.fetch("geonames")
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
  ) do
    def result?
      true
    end
  end

  class NoResultFound
    def geoname_id() end
    def name() end
    def country_code() end
    def admin_id4() end
    def admin_id3() end
    def admin_id2() end
    def admin_id1() end
    def country_id() end

    def result?
      false
    end
  end
end
