# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :test do
	gem "quickdraw", github: "joeldrapper/quickdraw", ref: "8f2ab5b7d8f0d4a9edb0e9297403326de57d5825"
end

group :development, :test do
	gem "rubocop", platform: :ruby
end

group :development do
	gem "ruby-lsp", platform: :ruby
end

gem "irb"
gem "openssl"
