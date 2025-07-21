# frozen_string_literal: true

module Refract
	class ShareableConstantNode < Node
		def initialize(prism_node: nil, write:)
			@prism_node = prism_node => Prism::Node | nil
			@write = write
			freeze
		end

		attr_accessor :write
	end
end
