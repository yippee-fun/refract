# frozen_string_literal: true

module Refract
	class ArrayNode < Node
		def initialize(prism_node: nil, elements:)
			@prism_node = prism_node => Prism::Node | nil
			@elements = elements
			freeze
		end

		attr_accessor :elements
	end
end
