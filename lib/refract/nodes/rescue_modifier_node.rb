# frozen_string_literal: true

module Refract
	class RescueModifierNode < Node
		def initialize(prism_node: nil, expression:, rescue_expression:)
			@prism_node = prism_node => Prism::Node | nil
			@expression = expression
			@rescue_expression = rescue_expression
			freeze
		end

		attr_accessor :expression, :rescue_expression
	end
end
