# frozen_string_literal: true

module Refract
	class SuperNode < Node
		def initialize(arguments:, block:)
			@arguments = arguments
			@block = block
		end

		attr_accessor :arguments, :block
	end
end
