# frozen_string_literal: true

module Refract
	class CallTargetNode < Node
		def initialize(prism_node: nil, receiver:, name:)
			@prism_node = prism_node => Prism::Node | nil
			@receiver = receiver
			@name = name
			freeze
		end

		attr_accessor :receiver, :name
	end
end
