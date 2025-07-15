# frozen_string_literal: true

module Refract
	class ArgumentsNode < Node
		def initialize(arguments:)
			@arguments = arguments
		end

		attr_accessor :arguments
	end
end
