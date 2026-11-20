# frozen_string_literal: true

module Refract
	class LocalVariableTargetNode < Node
		def initialize(prism_node: nil, name:, depth:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@depth = depth
			freeze
		end

		attr_accessor :name, :depth
	end
end
