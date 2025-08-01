# frozen_string_literal: true

module Refract
	class ConstantPathAndWriteNode < Node
		def initialize(prism_node: nil, target:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@target = target
			@value = value
			freeze
		end

		attr_accessor :target, :value
	end
end
