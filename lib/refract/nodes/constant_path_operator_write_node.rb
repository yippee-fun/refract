# frozen_string_literal: true

module Refract
	class ConstantPathOperatorWriteNode < Node
		def initialize(prism_node: nil, target:, value:, binary_operator:)
			@prism_node = prism_node => Prism::Node | nil
			@target = target
			@value = value
			@binary_operator = binary_operator
			freeze
		end

		attr_accessor :target, :value, :binary_operator
	end
end
