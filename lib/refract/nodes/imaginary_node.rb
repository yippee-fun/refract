# frozen_string_literal: true

module Refract
	class ImaginaryNode < Node
		def initialize(prism_node: nil, numeric:)
			@prism_node = prism_node => Prism::Node | nil
			@numeric = numeric
			freeze
		end

		attr_accessor :numeric
	end
end
