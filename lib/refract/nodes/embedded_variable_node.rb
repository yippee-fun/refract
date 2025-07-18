# frozen_string_literal: true

module Refract
	class EmbeddedVariableNode < Node
		def initialize(prism_node: nil, variable:)
			@prism_node = prism_node => Prism::Node | nil
			@variable = variable
			freeze
		end

		attr_accessor :variable
	end
end
