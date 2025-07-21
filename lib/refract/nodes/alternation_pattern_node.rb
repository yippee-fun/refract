# frozen_string_literal: true

module Refract
	class AlternationPatternNode < Node
		def initialize(prism_node: nil, left:, right:)
			@prism_node = prism_node => Prism::Node | nil
			@left = left
			@right = right
			freeze
		end

		attr_accessor :left, :right
	end
end
