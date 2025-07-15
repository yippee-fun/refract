# frozen_string_literal: true

module Refract
	class FindPatternNode < Node
		def initialize(constant:, left:, requireds:, right:)
			@constant = constant
			@left = left
			@requireds = requireds
			@right = right
		end

		attr_accessor :constant, :left, :requireds, :right
	end
end
