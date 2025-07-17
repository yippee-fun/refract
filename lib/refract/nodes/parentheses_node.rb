# frozen_string_literal: true

module Refract
	class ParenthesesNode < Node
		def initialize(prism_node: nil, body:)
			@prism_node = prism_node => Prism::Node | nil
			@body = body
		end

		attr_accessor :body
	end
end
