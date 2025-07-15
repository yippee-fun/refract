# frozen_string_literal: true

module Refract
	class ConstantPathOperatorWriteNode < Node
		def initialize(target:, value:, binary_operator:)
			@target = target
			@value = value
			@binary_operator = binary_operator
		end

		attr_accessor :target, :value, :binary_operator
	end
end
