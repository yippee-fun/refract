# frozen_string_literal: true

module Refract
	class FlipFlopNode < Node
		def initialize(left:, right:, exclude_end:)
			@left = left
			@right = right
			@exclude_end = exclude_end
		end

		attr_accessor :left, :right, :exclude_end
	end
end
