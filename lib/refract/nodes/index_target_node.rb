# frozen_string_literal: true

module Refract
	class IndexTargetNode < Node
		def initialize(receiver:, arguments:, block:)
			@receiver = receiver
			@arguments = arguments
			@block = block
		end

		attr_reader :receiver, :arguments, :block
	end
end
