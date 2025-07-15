# frozen_string_literal: true

module Refract
	class ArrayNode < Node
		def initialize(elements:)
			@elements = elements
		end

		attr_accessor :elements
	end
end
