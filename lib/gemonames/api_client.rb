require "values"
require "gemonames/results"
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
        q: query,
        country: country_code,
        maxRows: limit
    end

    def find(query, **args)
      one_result(
        search(query, **args.merge(limit: 1)),
        null_result: -> { SearchResult.with_nil }
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
        null_result: -> { SearchResult.with_nil }
      )
    end

    def countries_info(country_code: nil)
      perform :country_info,
        wrapper: country_info_wrapper,
        country: country_code
    end

    def country_info(country_code:)
      one_result(
        countries_info(country_code: country_code),
        null_result: -> { CountryInfoResult.with_nil }
      )
    end

    def country_regions(country_code:, feature_code:, limit: 100)
      perform(
        :search,
        wrapper: search_result_wrapper,
        country: country_code,
        fcode: feature_code,
        maxRows: limit
      )
    end

    def timezone(latitude:, longitude:)
      response = WebServices.public_send(
        :timezone,
        connection,
        lat: latitude,
        lng: longitude,
      ).tap { |r| raise_on_error(r) }

      timezone_wrapper[response.body]
    end

    def perform(endpoint, wrapper: search_result_wrapper, **args)
      extract_payload(
        WebServices.public_send(endpoint, connection, **args),
        wrapper
      )
    end

    private

    def one_result(results, null_result: -> {})
      results.first || null_result.call
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

    def wrapper(klass, mapping)
      lambda do |result|
        required = mapping[:required]
          .each_with_object({}) do |(k, v), memo|
            memo.merge!(k => result.fetch(v))
          end
        optional = mapping[:optional]
          .each_with_object({}) do |(k, v), memo|
            memo.merge!(k => result[v])
          end
        klass.with(
          required
          .merge(optional)
          .merge(result: true)
        )
      end
    end

    def search_result_wrapper
      wrapper(SearchResult, SEARCH_RESULT_MAPPING)
    end

    def country_info_wrapper
      wrapper(CountryInfoResult, COUNTRY_INFO_MAPPING)
    end

    def timezone_wrapper
      wrapper(TimezoneResult, TIMEZONE_MAPPING)
    end

    SEARCH_RESULT_MAPPING = {
      optional:  {
        admin_id1: "adminId1".freeze,
        admin_id2: "adminId2".freeze,
        admin_id3: "adminId3".freeze,
        admin_id4: "adminId4".freeze,
        country_id: "countryId".freeze,
        feature_code: "fcode".freeze,
      },
      required: {
        country_code: "countryCode".freeze,
        geoname_id: "geonameId".freeze,
        latitude: "lat".freeze,
        longitude: "lng".freeze,
        name: "name".freeze,
      }
    }

    COUNTRY_INFO_MAPPING = {
      optional: {
      },
      required: {
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
    }

    TIMEZONE_MAPPING = {
      optional: {
        country_code: "countryCode".freeze,
        country_name: "countryName".freeze,
        timezone_id: "timezoneId".freeze,
      },
      required: {
        gmt_offset: "gmtOffset".freeze,
        raw_offset: "rawOffset".freeze,
        dst_offset: "dstOffset".freeze,
        latitude: "lat".freeze,
        longitude: "lng".freeze,
      }
    }
  end
end
