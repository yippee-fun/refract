# frozen_string_literal: true

module Refract
	class AlternationPatternNode < Node
		def initialize(left:, right:)
			@left = left
			@right = right
		end

		attr_accessor :left, :right
	end
end
