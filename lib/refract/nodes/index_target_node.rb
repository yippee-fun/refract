# frozen_string_literal: true

module Refract
	class IndexTargetNode < Node
		def initialize(prism_node: nil, receiver:, arguments:, block:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@arguments = arguments
			@block = block
		end

		attr_reader :receiver, :arguments, :block
	end
end
