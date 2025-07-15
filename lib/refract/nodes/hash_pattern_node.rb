# frozen_string_literal: true

module Refract
	class HashPatternNode < Node
		def initialize(elements:, rest:)
			@elements = elements
			@rest = rest
		end

		attr_accessor :elements, :rest
	end
end
