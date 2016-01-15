require "values"
require "gemonames/web_services"

module Gemonames
  class ApiError < StandardError
    def initialize(message, error_code)
      super(message)
      @error_code = error_code
    end

    def to_s
      "#{super} (error code: #{@error_code})"
    end
  end

  class ApiClient
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def search(query, country_code:, limit: 10)
      perform :search,
        wrapper: search_result_wrapper,
        query: query,
        country: country_code,
        maxRows: limit
    end

    def find(query, **args)
      one_result(
        search(query, **args.merge(limit: 1)),
        null_result: search_null_result
      )
    end

    def reverse_search(latitude:, longitude:, limit: 10)
      perform :find_nearby_place_name,
        wrapper: search_result_wrapper,
        lat: latitude,
        lng: longitude,
        maxRows: limit
    end

    def reverse_find(**args)
      one_result(
        reverse_search(**args.merge(limit: 1)),
        null_result: search_null_result
      )
    end

    def countries_info(country: nil)
      perform :country_info,
        wrapper: country_info_wrapper,
        country: country
    end

    def country_info(country:)
      one_result(
        countries_info(country: country),
        null_result: country_info_null_result
      )
    end

    def perform(endpoint, wrapper: search_result_wrapper, **args)
      extract_payload(
        WebServices.public_send(endpoint, connection, **args),
        wrapper
      )
    end

    private

    def one_result(results, null_result:)
      results.first || null_result
    end

    def extract_payload(response, wrapper)
      raise_on_error(response)

      response.body
        .fetch("geonames")
        .lazy
        .map(&wrapper)
    end

    def raise_on_error(response)
      status = response.body["status"]
      if status
        raise ApiError.new(*status.values_at("message", "value"))
      end
    end

    def search_null_result
      @search_null_result ||= SearchResult.with(
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

    def country_info_null_result
      @country_info_null_result ||= CountryInfoResult.with(
        country_name: nil,
        currency_code: nil,
        fips_code: nil,
        country_code: nil,
        iso_numeric: nil,
        north: nil,
        capital: nil,
        continent_name: nil,
        area_in_sq_km: nil,
        languages: nil,
        iso_alpha3: nil,
        continent: nil,
        south: nil,
        east: nil,
        geoname_id: nil,
        west: nil,
        population: nil,
        result: false
      )
    end

    def search_result_wrapper
      lambda do |result|
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

    def country_info_wrapper
      lambda do |result|
        CountryInfoResult.with(
          COUNTRY_INFO_MAPPING
          .each_with_object({}) do |(k, v), memo|
            memo.merge!(k => result.fetch(v))
          end
          .merge(result: true)
        )
      end
    end

    COUNTRY_INFO_MAPPING = {
      country_name: "countryName".freeze,
      currency_code: "currencyCode".freeze,
      fips_code: "fipsCode".freeze,
      country_code: "countryCode".freeze,
      iso_numeric: "isoNumeric".freeze,
      north: "north".freeze,
      capital: "capital".freeze,
      continent_name: "continentName".freeze,
      area_in_sq_km: "areaInSqKm".freeze,
      languages: "languages".freeze,
      iso_alpha3: "isoAlpha3".freeze,
      continent: "continent".freeze,
      south: "south".freeze,
      east: "east".freeze,
      geoname_id: "geonameId".freeze,
      west: "west".freeze,
      population: "population".freeze,
    }
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

  CountryInfoResult = Value.new(
    :country_name,
    :currency_code,
    :fips_code,
    :country_code,
    :iso_numeric,
    :north,
    :capital,
    :continent_name,
    :area_in_sq_km,
    :languages,
    :iso_alpha3,
    :continent,
    :south,
    :east,
    :geoname_id,
    :west,
    :population,
    :result,
  ) do
    alias_method :result?, :result
    alias_method :present?, :result
  end
end
