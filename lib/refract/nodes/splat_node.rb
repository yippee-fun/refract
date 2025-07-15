# frozen_string_literal: true

module Refract
	class SplatNode < Node
		def initialize(expression:)
			@expression = expression
		end

		attr_accessor :expression
	end
end
