# Gemonames

[Geonames][] JSON API ruby client.

This library implements a small subset of the Geonames API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "gemonames"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gemonames

## Usage

```ruby
client = Gemonames.client(username: "demo")

# Find first result matching query "73000" in France:
client.find "73000", country_code: "fr"
#  => #<Gemonames::SearchResult geoname_id=3027422, name="Chambéry",
#  country_code="FR", admin_id4="6455250", admin_id3="3027421",
#  admin_id2="2975517", admin_id1="2983751", country_id="3017382">

# Return all result matching query "Pawnee" in US:
client.search "Pawnee", country_code: "US"
#  => [... array of results ...]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gemonames. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[geonames]: http://www.geonames.org
