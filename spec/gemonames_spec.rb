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

    it "returns empty result when http response not successful" do
      connection = double "connection",
        get: instance_double(
          "Faraday::Response",
          env: { status: 400 },
          body: {}
      )
      client = Gemonames.client(username: "demo", connection: connection)

      results = client.search("query", country_code: "si")

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

    it "returns empty result when http response not successful" do
      connection = double "connection",
        get: instance_double(
          "Faraday::Response",
          env: { status: 400 },
          body: {}
      )
      client = Gemonames.client(username: "demo", connection: connection)

      result = client.find("query", country_code: "si")

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
end
