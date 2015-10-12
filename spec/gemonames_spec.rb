require "spec_helper"

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
        )
      end
    end

    it "returns an empty result" do
      results = VCR.use_cassette "search-no-result" do
        client.search("UnknownPlace", country_code: "si")
      end

      expect(results).to be_empty
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
        )
      end
    end

    it "returns an empty result" do
      result = VCR.use_cassette "find-no-result" do
        client.find("UnknownPlace", country_code: "si")
      end

      expect(result.result?).to be_falsey
    end
  end
end
