# frozen_string_literal: true

module Refract
	class InterpolatedStringNode < Node
		def initialize(prism_node: nil, parts:)
			@prism_node = prism_node => Prism::Node | nil
			@parts = parts
		end

		attr_accessor :parts
	end
end
