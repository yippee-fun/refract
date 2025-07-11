# frozen_string_literal: true

require "zeitwerk"
module Refract
	Loader = Zeitwerk::Loader.for_gem.tap do |loader|
		loader.ignore("#{__dir__}/ruby_lsp")
		loader.collapse("#{__dir__}/refract/errors")
		loader.collapse("#{__dir__}/refract/nodes")
		loader.setup
	end

	PatternNode = Module.new
end
