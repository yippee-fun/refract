# frozen_string_literal: true

module Refract
	class NextNode < Node
		def initialize(prism_node: nil, arguments:)
			@prism_node = prism_node => Prism::Node | nil
			@arguments = arguments
		end

		attr_accessor :arguments
	end
end
