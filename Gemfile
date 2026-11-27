# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :test do
	gem "quickdraw", github: "joeldrapper/quickdraw", ref: "56f9c8c14b83f6d57a17458e960eefe542c7d79b"
end

group :development, :test do
	gem "rubocop"
end

group :development do
	gem "ruby-lsp", platform: :ruby
end

gem "irb"
gem "openssl", platform: :mri
