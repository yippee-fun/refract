# frozen_string_literal: true

module Refract
	class IntegerNode < Node
		def initialize(prism_node: nil, value:)
			@prism_node = prism_node => Prism::Node | nil
			@value = value
		end

		attr_accessor :value
	end
end
