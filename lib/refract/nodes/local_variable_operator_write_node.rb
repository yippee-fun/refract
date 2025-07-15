# frozen_string_literal: true

module Refract
	class LocalVariableOperatorWriteNode < Node
		def initialize(name:, value:, binary_operator:, depth:)
			@name = name
			@value = value
			@binary_operator = binary_operator
			@depth = depth
		end

		attr_accessor :name, :value, :binary_operator, :depth
	end
end
