# frozen_string_literal: true

module Refract
	class IndexTargetNode < Node
		def initialize(prism_node: nil, receiver:, arguments:, block:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@arguments = arguments
			@block = block
			freeze
		end

		attr_accessor :receiver, :arguments, :block
	end
end
