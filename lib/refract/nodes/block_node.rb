# frozen_string_literal: true

module Refract
	class BlockNode < Node
		def initialize(prism_node: nil, parameters:, body:)
			@prism_node = prism_node => Prism::Node | nil
			@parameters = parameters
			@body = body
		end

		attr_accessor :parameters, :body
	end
end
