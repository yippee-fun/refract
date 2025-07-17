# frozen_string_literal: true

module Refract
	class RangeNode < Node
		def initialize(prism_node: nil, left:, right:, exclude_end:)
			@prism_node = prism_node => Prism::Node | nil
			@left = left
			@right = right
			@exclude_end = exclude_end
		end

		attr_accessor :left, :right, :exclude_end
	end
end
