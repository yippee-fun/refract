# frozen_string_literal: true

module Refract
	class DefNode < Node
		def initialize(prism_node: nil, name:, receiver:, parameters:, body:)
			@prism_node = prism_node => Prism::Node | nil
			@name = name
			@receiver = receiver
			@parameters = parameters
			@body = body
			freeze
		end

		attr_accessor :name, :receiver, :parameters, :body
	end
end
