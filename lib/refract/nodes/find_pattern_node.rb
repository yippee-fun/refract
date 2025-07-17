# frozen_string_literal: true

module Refract
	class FindPatternNode < Node
		def initialize(prism_node: nil, constant:, left:, requireds:, right:)
			@prism_node = prism_node => Prism::Node | nil
			@constant = constant
			@left = left
			@requireds = requireds
			@right = right
		end

		attr_accessor :constant, :left, :requireds, :right
	end
end
