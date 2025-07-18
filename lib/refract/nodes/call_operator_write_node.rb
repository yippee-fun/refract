# frozen_string_literal: true

module Refract
	class CallOperatorWriteNode < Node
		def initialize(prism_node: nil, receiver:, read_name:, binary_operator:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@read_name = read_name
			@binary_operator = binary_operator
			@value = value
			freeze
		end

		attr_accessor :receiver, :read_name, :binary_operator, :value
	end
end
