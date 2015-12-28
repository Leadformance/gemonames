module Gemonames
  module WebServices
    module_function

    def search(connection, query:, country_code:, max_rows:)
      results = connection.get do |request|
        request.url "/searchJSON".freeze
        request.params[:q] = query
        request.params[:country] = country_code
        request.params[:maxRows] = max_rows
        request.params[:style] = "full".freeze
      end

      results.body
    end
  end
end
