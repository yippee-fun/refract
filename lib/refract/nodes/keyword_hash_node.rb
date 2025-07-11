# frozen_string_literal: true

module Refract
	class KeywordHashNode < Node
		def initialize(elements:)
			@elements = elements => Array
		end

		attr_reader :elements
	end
end
