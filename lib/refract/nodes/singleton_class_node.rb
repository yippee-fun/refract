# frozen_string_literal: true

module Refract
	class SingletonClassNode < Node
		def initialize(expression:, body:)
			@expression = expression
			@body = body
		end

		attr_accessor :expression, :body
	end
end
