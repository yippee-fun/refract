# frozen_string_literal: true

module Refract
	class ConstantPath < Node
		def initialize(prism_node: nil, parent:, name:)
			@prism_node = prism_node => Prism::Node | nil
			@parent = parent
			@name = name
		end

		attr_accessor :parent, :name
	end
end
