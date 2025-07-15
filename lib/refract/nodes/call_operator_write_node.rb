# frozen_string_literal: true

module Refract
	class CallOperatorWriteNode < Node
		def initialize(receiver:, read_name:, binary_operator:, value:)
			@receiver = receiver
			@read_name = read_name
			@binary_operator = binary_operator
			@value = value
		end

		attr_accessor :receiver, :read_name, :binary_operator, :value
	end
end
