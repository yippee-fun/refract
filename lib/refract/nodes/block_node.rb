# frozen_string_literal: true

module Refract
	class BlockNode < Node
		def initialize(prism_node: nil, parameters:, body:)
			@prism_node = prism_node => Prism::Node | nil
			@parameters = parameters
			@body = body
			freeze
		end

		attr_reader :parameters, :body
	end
end
