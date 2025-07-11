# frozen_string_literal: true

module Refract
	class AlternationPatternNode < Node
		def initialize(left:, right:)
			@left = left => Node
			@right = right => Node
		end

		attr_reader :left
		attr_reader :right
	end
end
