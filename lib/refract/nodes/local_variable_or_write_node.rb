# frozen_string_literal: true

module Refract
	class LocalVariableOrWriteNode < Node
		def initialize(prism_node: nil, name:, value:, depth:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@value = value
			@depth = depth
			freeze
		end

		attr_accessor :name, :value, :depth
	end
end
