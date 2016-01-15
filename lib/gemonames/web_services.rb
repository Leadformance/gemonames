module Gemonames
  module WebServices
    module_function

    def search(connection, query:, country:, maxRows:)
      connection.get do |request|
        request.url "/searchJSON".freeze
        request.params[:q] = query
        request.params[:country] = country
        request.params[:maxRows] = maxRows
        request.params[:style] = "full".freeze
      end
    end

    def find_nearby_place_name(connection, lat:, lng:, maxRows:)
      connection.get do |request|
        request.url "/findNearbyPlaceNameJSON".freeze
        request.params[:lat] = lat
        request.params[:lng] = lng
        request.params[:maxRows] = maxRows
        request.params[:style] = "full".freeze
      end
    end

    def country_info(connection, country: nil)
      connection.get do |request|
        request.url "/countryInfoJSON".freeze
        request.params[:country] = country if country
      end
    end
  end
end
