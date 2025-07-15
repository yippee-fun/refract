# frozen_string_literal: true

module Refract
	class InterpolatedSymbolNode < Node
		def initialize(parts:)
			@parts = parts
		end

		attr_accessor :parts
	end
end
