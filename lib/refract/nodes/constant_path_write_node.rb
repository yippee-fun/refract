# frozen_string_literal: true

module Refract
	class ConstantPathWriteNode < Node
		def initialize(prism_node: nil, target:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@target = target
			@value = value
		end

		attr_accessor :target, :value
	end
end
