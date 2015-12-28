require "spec_helper"
require "logger"

describe Gemonames do
  let(:client) { Gemonames.client(username: "demo") }

  describe "#search" do
    it "performs a search based on city and country code" do
      results = VCR.use_cassette "search-city-and-country-code" do
        client.search("Celje", limit: 5, country_code: "si")
      end

      aggregate_failures do
        expect(results.size).to eq(5)
        expect(results.first).to have_attributes(
          geoname_id: 3202781,
          name: "Celje",
          country_code: "SI",
          admin_id4: nil,
          admin_id3: nil,
          admin_id2: nil,
          admin_id1: "3202780",
          country_id: "3190538",
        )
      end
    end

    it "returns an empty result" do
      results = VCR.use_cassette "search-no-result" do
        client.search("UnknownPlace", country_code: "si")
      end

      expect(results).to be_empty
    end

    it "does logging when provided with a logger" do
      log_output = StringIO.new
      client = Gemonames.client(
        username: "demo",
        logger: Logger.new(log_output)
      )

      VCR.use_cassette "search-city-and-country-code" do
        client.search("Celje", limit: 5, country_code: "si")
      end

      log_output.rewind

      expect(log_output.read).to include(
        %Q{[Gemonames] method=GET status=200 url="http://api.geonames.org/searchJSON?}
      )
    end
  end

  describe "#find" do
    it "find a result based on city and country code" do
      result = VCR.use_cassette "find-city-and-country-code" do
        client.find("Celje", country_code: "si")
      end

      aggregate_failures do
        expect(result.result?).to be_truthy
        expect(result).to have_attributes(
          geoname_id: 3202781,
          name: "Celje",
          country_code: "SI",
          admin_id4: nil,
          admin_id3: nil,
          admin_id2: nil,
          admin_id1: "3202780",
          country_id: "3190538",
        )
      end
    end

    it "returns an empty result" do
      result = VCR.use_cassette "find-no-result" do
        client.find("UnknownPlace", country_code: "si")
      end

      expect(result.result?).to be_falsey
    end

    it "does logging when provided with a logger" do
      log_output = StringIO.new
      client = Gemonames.client(
        username: "demo",
        logger: Logger.new(log_output)
      )

      VCR.use_cassette "find-city-and-country-code" do
        client.find("Celje", country_code: "si")
      end

      log_output.rewind

      expect(log_output.read).to include(
        %Q{[Gemonames] method=GET status=200 url="http://api.geonames.org/searchJSON?}
      )
    end
  end

  describe "#reverse_find" do
    it "finds place based on latitude and longitude" do
      result = VCR.use_cassette "find-reverse" do
        client.reverse_find(latitude: 45.57, longitude: 5.9118)
      end

      aggregate_failures do
        expect(result.result?).to be_truthy
        expect(result).to have_attributes(
          name: "Cognin",
          geoname_id: 3024426,
          country_code: "FR",
          country_id: "3017382",
          admin_id1: "2983751",
          admin_id2: "2975517",
          admin_id3: "3027421",
          admin_id4: "6455252",
        )
      end
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
