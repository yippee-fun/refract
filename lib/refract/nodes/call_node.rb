# frozen_string_literal: true

module Refract
	class CallNode < Node
		def initialize(receiver:, message:, arguments:, block:)
			@receiver = receiver
			@message = message
			@arguments = arguments
			@block = block
		end

		attr_accessor :receiver, :message, :arguments, :block
	end
end
