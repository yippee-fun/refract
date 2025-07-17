# frozen_string_literal: true

module Refract
	class IndexAndWriteNode < Node
		def initialize(prism_node: nil, receiver:, arguments:, block:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@arguments = arguments
			@block = block
			@value = value
		end

		attr_accessor :receiver, :arguments, :block, :value
	end
end
