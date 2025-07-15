# frozen_string_literal: true

module Refract
	class RescueModifierNode < Node
		def initialize(expression:, rescue_expression:)
			@expression = expression
			@rescue_expression = rescue_expression
		end

		attr_accessor :expression, :rescue_expression
	end
end
