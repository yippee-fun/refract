# frozen_string_literal: true

module Refract
	class ArrayNode < Node
		def initialize(elements:)
			@elements = elements => Array
		end

		attr_reader :elements
	end
end
