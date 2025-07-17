# frozen_string_literal: true

module Refract
	class IndexOperatorWriteNode < Node
		def initialize(prism_node: nil, receiver:, arguments:, block:, binary_operator:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@arguments = arguments
			@block = block
			@binary_operator = binary_operator
			@value = value
		end

		attr_accessor :receiver, :arguments, :block, :binary_operator, :value
	end
end
