# frozen_string_literal: true

module Refract
	class CallNode < Node
		def initialize(prism_node: nil, receiver: nil, name:, arguments: nil, block: nil, safe_navigation: nil, variable_call: nil, attribute_write: nil)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@name = name => Symbol
			@arguments = arguments
			@block = block
			@safe_navigation = safe_navigation
			@variable_call = variable_call
			@attribute_write = attribute_write
			freeze
		end

		attr_accessor :receiver, :name, :arguments, :block, :safe_navigation, :variable_call, :attribute_write
	end
end
