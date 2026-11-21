# frozen_string_literal: true

module Refract
	class LocalVariableWriteNode < Node
		def initialize(prism_node: nil, name:, value:, depth:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@value = value
			@depth = depth
			freeze
		end

		attr_reader :name, :value, :depth
	end
end
