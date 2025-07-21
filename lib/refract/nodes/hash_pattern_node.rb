# frozen_string_literal: true

module Refract
	class HashPatternNode < Node
		def initialize(prism_node: nil, elements:, rest:)
			@prism_node = prism_node => Prism::Node | nil
			@elements = elements
			@rest = rest
			freeze
		end

		attr_accessor :elements, :rest
	end
end
