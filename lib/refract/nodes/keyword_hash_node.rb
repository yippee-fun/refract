# frozen_string_literal: true

module Refract
	class KeywordHashNode < Node
		def initialize(elements:)
			@elements = elements
		end

		attr_accessor :elements
	end
end
