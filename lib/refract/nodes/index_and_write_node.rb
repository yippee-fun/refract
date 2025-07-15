# frozen_string_literal: true

module Refract
	class IndexAndWriteNode < Node
		def initialize(receiver:, arguments:, block:, value:)
			@receiver = receiver
			@arguments = arguments
			@block = block
			@value = value
		end

		attr_accessor :receiver, :arguments, :block, :value
	end
end
