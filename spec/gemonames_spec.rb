require "logger"

describe Gemonames do
  describe ".client" do
    it "builds an ApiClient with given username" do
      client = Gemonames.client(username: "name-of-user")

      expect(client.connection.params)
        .to match(hash_including(username: "name-of-user"))
    end

    it "builds an ApiClient with given token" do
      client = Gemonames.client(username: "name-of-user", token: "token-of-user")

      expect(client.connection.params)
        .to match(hash_including(token: "token-of-user"))
    end
  end

  describe ".build_connection" do
    it "uses free endpoint when initialized without token" do
      connection = Gemonames.build_connection(
        username: "demo",
        token: nil,
        logger: nil,
      )
      expect(connection.url_prefix).to eq(URI("http://api.geonames.org"))
    end

    it "uses premium endpoint when initialized with a token" do
      connection = Gemonames.build_connection(
        username: "demo",
        token: "imaginary-demo-token",
        logger: nil,
      )
      expect(connection.url_prefix).to eq(URI("http://ws.geonames.net"))
    end

    it "does logging when provided with a logger" do
      log_output = StringIO.new
      connection = Gemonames.build_connection(
        username: "demo",
        logger: Logger.new(log_output),
        token: nil,
      )

      VCR.use_cassette "search-city-and-country-code" do
        connection.get("searchJSON", q: "Celje", country: "si", maxRows: 5, style: "full")
      end

      log_output.rewind

      expect(log_output.read).to include(
        %Q{[Gemonames] method=GET status=200 url="http://api.geonames.org/searchJSON?}
      )
    end
  end
end
