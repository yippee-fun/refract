# frozen_string_literal: true

module Refract
	class CapturePatternNode < Node
		def initialize(prism_node: nil, value:, target:)
			@prism_node = prism_node => Prism::Node | nil
			@value = value
			@target = target
		end

		attr_accessor :value, :target
	end
end
