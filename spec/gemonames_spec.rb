require "logger"

describe Gemonames do
  let(:client) { Gemonames.client(username: "demo") }

  describe ".build_connection" do
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
      token: "immaginary-demo-token",
      logger: nil,
    )
    expect(connection.url_prefix).to eq(URI("http://ws.geonames.net"))
  end
end
