module Gemonames
  SearchResult = Value.new(
    :geoname_id,
    :name,
    :country_code,
    :admin_id4,
    :admin_id3,
    :admin_id2,
    :admin_id1,
    :country_id,
    :feature_code,
    :result,
  ) do
    alias_method :result?, :result
    alias_method :present?, :result

    def self.with_nil
      with(
        geoname_id: nil,
        name: nil,
        country_code: nil,
        admin_id4: nil,
        admin_id3: nil,
        admin_id2: nil,
        admin_id1: nil,
        country_id: nil,
        feature_code: nil,
        result: false
      )
    end
  end

  CountryInfoResult = Value.new(
    :country_name,
    :currency_code,
    :fips_code,
    :country_code,
    :iso_numeric,
    :north,
    :capital,
    :continent_name,
    :area_in_sq_km,
    :languages,
    :iso_alpha3,
    :continent,
    :south,
    :east,
    :geoname_id,
    :west,
    :population,
    :result,
  ) do
    alias_method :result?, :result
    alias_method :present?, :result

    def self.with_nil
      with(
        country_name: nil,
        currency_code: nil,
        fips_code: nil,
        country_code: nil,
        iso_numeric: nil,
        north: nil,
        capital: nil,
        continent_name: nil,
        area_in_sq_km: nil,
        languages: nil,
        iso_alpha3: nil,
        continent: nil,
        south: nil,
        east: nil,
        geoname_id: nil,
        west: nil,
        population: nil,
        result: false
      )
    end
  end
end
