# frozen_string_literal: true

module Refract
	class ConstantOperatorWriteNode < Node
		def initialize(name:, value:, binary_operator:)
			@name = name
			@value = value
			@binary_operator = binary_operator
		end

		attr_accessor :name, :value, :binary_operator
	end
end
