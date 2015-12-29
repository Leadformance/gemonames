require "gemonames/web_services"

module Gemonames
  describe ApiClient do
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

        expect(results.any?).to eq(false)
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
    end

    describe "#reverse_search" do
      it "finds place based on latitude and longitude" do
        results = VCR.use_cassette "reverse-search" do
          client.reverse_search(latitude: 45.57, longitude: 5.9118)
        end

        aggregate_failures do
          expect(results.first).to have_attributes(
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
  end
end
