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
          expect(result.present?).to be_truthy
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

        expect(result.present?).to be_falsey
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
        result = VCR.use_cassette "reverse-find" do
          client.reverse_find(latitude: 45.57, longitude: 5.9118)
        end

        aggregate_failures do
          expect(result.present?).to be_truthy
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

    describe "#perfom" do
      let(:client) { Gemonames.client(username: "there-is-no-chance-this-client-exists") }
      it "raises ApiError when api responds with 'status' key" do
        VCR.use_cassette "search-with-missing-parameters" do
          expect{
            client.perform(
              :search,
              q: nil,
              country: nil,
              maxRows: 1
            )
          }.to raise_error ApiError
        end
      end
    end

    describe "#countries_info" do
      it "returns all countries info" do
        results = VCR.use_cassette "country-info-all-countries" do
          client.countries_info
        end

        aggregate_failures do
          expect(results.count).to eq(250)
          expect(results.first).to(
            have_attributes(
              country_name: "Andorra",
              currency_code: "EUR",
              fips_code: "AN",
              country_code: "AD",
              iso_numeric: "020",
              north: 42.65604389629997,
              capital: "Andorra la Vella",
              continent_name: "Europe",
              area_in_sq_km: "468.0",
              languages: "ca",
              iso_alpha3: "AND",
              continent: "EU",
              south: 42.42849259876837,
              east: 1.7865427778319827,
              geoname_id: 3041565,
              west: 1.4071867141112762,
              population: "84000",
              result: true
            )
          )
        end
      end
    end

    describe "#country_info" do
      it "returns one country info" do
        result = VCR.use_cassette "country-info-poland" do
          client.country_info(country: "pl")
        end

        aggregate_failures do
          expect(result.present?).to be_truthy
          expect(result).to(
            have_attributes(
              country_name: "Poland",
              currency_code: "PLN",
              fips_code: "PL",
              country_code: "PL",
              iso_numeric: "616",
              north: 54.839138,
              capital: "Warsaw",
              continent_name: "Europe",
              area_in_sq_km: "312685.0",
              languages: "pl",
              iso_alpha3: "POL",
              continent: "EU",
              south:  49.006363,
              east: 24.150749,
              geoname_id: 798544,
              west: 14.123,
              population: "38500000",
              result: true
            )
          )
        end
      end
    end

    describe "#country_regions" do
      it "returns country regions at provided admin level" do
        results = VCR.use_cassette "country-regions-at-admin-level" do
          client.country_regions(country_code: "si", fcode: "ADM1", limit: 500)
        end

        result = results.find { |region| region.geoname_id == 3239050 }
        aggregate_failures do
          expect(results.size).to eq(210)
          expect(result).to have_attributes(
            geoname_id: 3239050,
            name: "Hrpelje-Kozina",
            country_code: "SI",
            admin_id4: nil,
            admin_id3: nil,
            admin_id2: nil,
            admin_id1: "3239050",
            country_id: "3190538",
          )
        end
      end
    end
  end
end
