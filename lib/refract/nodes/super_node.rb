# frozen_string_literal: true

module Refract
	class SuperNode < Node
		def initialize(prism_node: nil, arguments:, block:)
			@prism_node = prism_node => Prism::Node | nil
			@arguments = arguments
			@block = block
			freeze
		end

		attr_accessor :arguments, :block
	end
end
