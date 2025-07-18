# frozen_string_literal: true

module Refract
	class OrNode < Node
		def initialize(prism_node: nil, left:, operator:, right:)
			@prism_node = prism_node => Prism::Node | nil
			@left = left
			@operator = operator
			@right = right
			freeze
		end

		attr_accessor :left, :operator, :right
	end
end
