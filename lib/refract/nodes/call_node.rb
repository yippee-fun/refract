# frozen_string_literal: true

module Refract
	class CallNode < Node
		def initialize(receiver:, message:, arguments:)
			@receiver = receiver => Node | nil
			@message = message => String
			@arguments = arguments => ArgumentsNode | nil
		end

		attr_reader :receiver
		attr_reader :message
		attr_reader :arguments
	end
end
