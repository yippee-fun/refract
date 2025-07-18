# frozen_string_literal: true

module Refract
	class UndefNode < Node
		def initialize(prism_node: nil, names:)
			@prism_node = prism_node => Prism::Node | nil
			@names = names
			freeze
		end

		attr_accessor :names
	end
end
