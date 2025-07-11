# frozen_string_literal: true

require_relative "lib/refract/version"

Gem::Specification.new do |spec|
	spec.name = "refract"
	spec.version = Refract::VERSION
	spec.authors = ["Joel Drapper"]
	spec.email = ["joel@drapper.me"]

	spec.summary = "Refract"
	spec.description = "Refract"
	spec.homepage = "https://github.com/yippee-fun/refract"
	spec.license = "MIT"
	spec.required_ruby_version = ">= 3.1"

	spec.metadata["homepage_uri"] = spec.homepage
	spec.metadata["source_code_uri"] = "https://github.com/yippee-fun/refract"
	spec.metadata["funding_uri"] = "https://github.com/sponsors/joeldrapper"

	spec.files = Dir[
		"README.md",
		"LICENSE.txt",
		"lib/**/*.rb"
	]

	spec.require_paths = ["lib"]

	spec.metadata["rubygems_mfa_required"] = "true"

	spec.add_dependency "prism"
	spec.add_dependency "zeitwerk"
end
