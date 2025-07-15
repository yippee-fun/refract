# frozen_string_literal: true

module Refract
	class ParenthesesNode < Node
		def initialize(body:)
			@body = body
		end

		attr_accessor :body
	end
end
