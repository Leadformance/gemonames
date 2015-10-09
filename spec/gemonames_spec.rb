require "spec_helper"

describe Gemonames do
  let(:client) { Gemonames.client(username: "demo") }

  it "performs a search based on city and country code" do
    result = VCR.use_cassette "search-city-and-country-code" do
      client.search("Celje", country_code: "si")
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
    result = VCR.use_cassette "search-no-result" do
      client.search("UnknownPlace", country_code: "si")
    end

    expect(result.result?).to be_falsey
  end
end
