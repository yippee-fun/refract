# frozen_string_literal: true

module Refract
	class KeywordHashNode < Node
		def initialize(prism_node: nil, elements:)
			@prism_node = prism_node => Prism::Node | nil
			@elements = elements
		end

		attr_accessor :elements
	end
end
