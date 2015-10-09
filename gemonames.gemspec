lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gemonames/version"

Gem::Specification.new do |spec|
  spec.name          = "gemonames"
  spec.version       = Gemonames::VERSION
  spec.authors       = ["Leadformance"]
  spec.email         = ["dev@leadformance.com"]

  spec.summary       = %q{geonames.org JSON API client}
  spec.description   = %q{Implements a small subset of the geonames.org JSON API on top of Faraday.}
  spec.homepage      = "https://github.com/Leaformance/gemonames"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "values"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
