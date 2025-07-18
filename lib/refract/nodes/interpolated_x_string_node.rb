# frozen_string_literal: true

module Refract
	class InterpolatedXStringNode < Node
		def initialize(prism_node: nil, parts:)
			@prism_node = prism_node => Prism::Node | nil
			@parts = parts
			freeze
		end

		attr_accessor :parts
	end
end
