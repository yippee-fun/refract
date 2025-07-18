# frozen_string_literal: true

module Refract
	class CallOrWriteNode < Node
		def initialize(prism_node: nil, receiver:, read_name:, value:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@read_name = read_name
			@value = value
			freeze
		end

		attr_accessor :receiver, :read_name, :value
	end
end
