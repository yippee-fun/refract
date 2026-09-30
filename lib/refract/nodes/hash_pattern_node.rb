# frozen_string_literal: true

module Refract
	class HashPatternNode < Node
		def initialize(prism_node: nil, constant: nil, elements:, rest:)
			@prism_node = prism_node => Prism::Node | nil
			@constant = constant
			@elements = elements
			@rest = rest
			freeze
		end

		attr_accessor :constant, :elements, :rest
	end
end
