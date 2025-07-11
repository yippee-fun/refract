# frozen_string_literal: true

module Refract
	class ArgumentsNode < Node
		def initialize(arguments:)
			@arguments = arguments => Array
		end

		attr_reader :arguments
	end
end
