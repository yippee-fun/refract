# frozen_string_literal: true

module Refract
	class MatchRequiredNode < Node
		def initialize(prism_node: nil, value:, pattern:)
			@prism_node = prism_node => Prism::Node | nil
			@value = value
			@pattern = pattern
		end

		attr_accessor :value, :pattern
	end
end
