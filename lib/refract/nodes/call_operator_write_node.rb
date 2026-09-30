# frozen_string_literal: true

module Refract
	class CallOperatorWriteNode < Node
		def initialize(prism_node: nil, receiver:, read_name:, binary_operator:, value:, safe_navigation: nil)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@read_name = read_name
			@binary_operator = binary_operator
			@value = value
			@safe_navigation = safe_navigation
			freeze
		end

		attr_accessor :receiver, :read_name, :binary_operator, :value, :safe_navigation
	end
end
