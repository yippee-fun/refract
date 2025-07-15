# frozen_string_literal: true

module Refract
	class BlockArgumentNode < Node
		def initialize(expression:)
			@expression = expression
		end

		attr_accessor :expression
	end
end
