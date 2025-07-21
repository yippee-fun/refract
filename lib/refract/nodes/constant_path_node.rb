# frozen_string_literal: true

module Refract
	class ConstantPathNode < Node
		def initialize(prism_node: nil, parent: nil, name:)
			@prism_node = prism_node => Prism::Node | nil
			@parent = parent
			@name = name
			freeze
		end

		attr_accessor :parent, :name
	end
end
