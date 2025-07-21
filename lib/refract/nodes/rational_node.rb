# frozen_string_literal: true

module Refract
	class RationalNode < Node
		def initialize(prism_node: nil, numerator:, denominator:)
			@prism_node = prism_node => Prism::Node | nil
			@numerator = numerator
			@denominator = denominator
			freeze
		end

		attr_accessor :numerator, :denominator
	end
end
