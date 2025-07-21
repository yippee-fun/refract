# frozen_string_literal: true

module Refract
	class LocalVariableOperatorWriteNode < Node
		def initialize(prism_node: nil, name:, value:, binary_operator:, depth:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@value = value
			@binary_operator = binary_operator
			@depth = depth
			freeze
		end

		attr_accessor :name, :value, :binary_operator, :depth
	end
end
