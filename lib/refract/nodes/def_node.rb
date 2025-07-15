# frozen_string_literal: true

module Refract
	class DefNode < Node
		def initialize(name:, receiver:, parameters:, body:)
			@name = name
			@receiver = receiver
			@parameters = parameters
			@body = body
		end

		attr_accessor :name, :receiver, :parameters, :body
	end
end
