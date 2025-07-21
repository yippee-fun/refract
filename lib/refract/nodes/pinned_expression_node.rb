# frozen_string_literal: true

module Refract
	class PinnedExpressionNode < Node
		def initialize(prism_node: nil, expression:)
			@prism_node = prism_node => Prism::Node | nil
			@expression = expression
			freeze
		end

		attr_accessor :expression
	end
end
