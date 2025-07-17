# frozen_string_literal: true

module Refract
	class CallNode < Node
		def initialize(prism_node: nil, receiver:, message:, arguments:, block:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@message = message
			@arguments = arguments
			@block = block
		end

		attr_accessor :receiver, :message, :arguments, :block
	end
end
