# frozen_string_literal: true

module Refract
	class SplatNode < Node
		def initialize(expression:)
			@expression = expression => Node
		end

		attr_reader :expression
	end
end
