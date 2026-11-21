# frozen_string_literal: true

module Refract
	class InstanceVariableOrWriteNode < Node
		def initialize(prism_node: nil, name:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@value = value
			freeze
		end

		attr_reader :name, :value
	end
end
