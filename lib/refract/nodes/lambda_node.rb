# frozen_string_literal: true

module Refract
	class LambdaNode < Node
		def initialize(prism_node: nil, parameters:, body:)
			@prism_node = prism_node => Prism::Node | nil
			@parameters = parameters
			@body = body
			freeze
		end

		attr_accessor :parameters, :body
	end
end
