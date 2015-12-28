require "gemonames/version"
require "gemonames/web_services"
require "values"
require "faraday"
require "faraday_middleware"
require "gemonames/response_logger"

module Gemonames
  module_function

  FREE_ENDPOINT = "http://api.geonames.org"
  PREMIUM_ENDPOINT = "http://ws.geonames.net"

  def client(username:, connection: nil, token: nil, logger: nil)
    connection ||= build_connection(
      username: username, token: token, logger: logger
    )
    ApiClient.new(connection)
  end

  def build_connection(username:, token:, logger:)
    url = token ? PREMIUM_ENDPOINT : FREE_ENDPOINT
    Faraday.new(url: url) do |faraday|
      faraday.response :json
      faraday.use ResponseLogger, logger if logger
      faraday.adapter Faraday.default_adapter
      faraday.params[:username] = username
      faraday.params[:token] = token if token
    end
  end

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
        query: query, country: country_code, maxRows: 1
    end

    def reverse_find(latitude:, longitude:)
      perform_find :find_nearby_place_name,
        lat: latitude, lng: longitude, maxRows: 1
    end

    private

    def perform_search(endpoint, **args)
      results = WebServices
        .public_send(endpoint, connection, **args)
        .body
        .fetch("geonames")

      results.map { |result|
        wrap_in_search_result(result)
      }
    end

    def perform_find(endpoint, **args)
      results = WebServices
        .public_send(endpoint, connection, **args)
        .body
        .fetch("geonames")

      if results.any?
        wrap_in_search_result(results.first)
      else
        NoResultFound.new
      end
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
