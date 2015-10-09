$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "gemonames"

require "vcr"
VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :faraday
end
