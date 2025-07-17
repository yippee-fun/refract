# frozen_string_literal: true

module Refract
	class GlobalVariableWriteNode < Node
		def initialize(prism_node: nil, name:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@value = value
		end

		attr_accessor :name, :value
	end
end
