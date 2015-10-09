require "gemonames/version"
require "values"
require "faraday"
require "faraday_middleware"

module Gemonames
  module_function
  BASE_API_URL = "http://api.geonames.org"

  def client(username:, connection: nil)
    connection ||= build_connection(username: username)
    ApiClient.new(connection)
  end

  def build_connection(username:)
    Faraday.new(url: BASE_API_URL) do |faraday|
      faraday.response :json
      faraday.params[:username] = username
      faraday.adapter Faraday.default_adapter
    end
  end

  class ApiClient
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def search(query, country_code:)
      results = connection.get do |request|
        request.url "/searchJSON".freeze
        request.params[:q] = query
        request.params[:country] = country_code
        request.params[:maxRows] = 1
        request.params[:style] = "short".freeze
      end

      result = results.body.fetch("geonames").first

      if result
        SearchResult.with(
          geoname_id: result.fetch("geonameId"),
          name: result.fetch("name"),
          country_code: result.fetch("countryCode"),
        )
      else
        NoSearchResult.new
      end
    end
  end

  SearchResult = Value.new(:geoname_id, :name, :country_code) do
    def result?
      true
    end
  end

  class NoSearchResult
    def geoname_id() end
    def name() end
    def country_code() end

    def result?
      false
    end
  end
end
