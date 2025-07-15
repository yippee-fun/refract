# frozen_string_literal: true

module Refract
	class ReturnNode < Node
		def initialize(arguments:)
			@arguments = arguments
		end

		attr_accessor :arguments
	end
end
