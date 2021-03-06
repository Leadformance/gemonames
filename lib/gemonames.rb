require "faraday"
require "faraday_middleware"
require "gemonames/version"
require "gemonames/api_client"
require "gemonames/response_logger"

module Gemonames
  module_function

  FREE_ENDPOINT = "http://api.geonames.org"
  PREMIUM_ENDPOINT = "http://ws.geonames.net"

  def client(username:, token: nil, logger: nil)
    ApiClient.new(
      build_connection(username: username, token: token, logger: logger)
    )
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
end
