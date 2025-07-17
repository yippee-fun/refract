# frozen_string_literal: true

module Refract
	class ForwardingSuperNode < Node
		def initialize(prism_node: nil, block:)
			@prism_node = prism_node => Prism::Node | nil
			@block = block
		end

		attr_accessor :block
	end
end
