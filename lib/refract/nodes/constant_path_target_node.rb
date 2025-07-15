# frozen_string_literal: true

module Refract
	class ConstantPathTargetNode < Node
		def initialize(parent:, name:)
			@parent = parent
			@name = name
		end

		attr_accessor :parent, :name
	end
end
