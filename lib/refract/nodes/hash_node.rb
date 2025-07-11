# frozen_string_literal: true

module Refract
	class HashNode < Node
		def initialize(elements:)
			@elements = elements => Array
		end

		attr_reader :elements
	end
end
