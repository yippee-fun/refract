# frozen_string_literal: true

module Refract
	class PinnedExpressionNode < Node
		def initialize(expression:)
			@expression = expression
		end

		attr_accessor :expression
	end
end
