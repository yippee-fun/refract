# frozen_string_literal: true

module Refract
	class SingletonClassNode < Node
		def initialize(prism_node: nil, expression:, body:)
			@prism_node = prism_node => Prism::Node | nil
			@expression = expression
			@body = body
		end

		attr_accessor :expression, :body
	end
end
