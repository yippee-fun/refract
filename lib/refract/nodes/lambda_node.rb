# frozen_string_literal: true

module Refract
	class LambdaNode < Node
		def initialize(parameters:, body:)
			@parameters = parameters
			@body = body
		end

		attr_accessor :parameters, :body
	end
end
