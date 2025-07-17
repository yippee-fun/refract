# frozen_string_literal: true

module Refract
	class ClassVariableOperatorWriteNode < Node
		def initialize(prism_node: nil, name:, value:, binary_operator:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@value = value
			@binary_operator = binary_operator
		end

		attr_accessor :name, :value, :binary_operator
	end
end
