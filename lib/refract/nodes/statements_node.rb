# frozen_string_literal: true

module Refract
	class StatementsNode < Node
		def initialize(body:)
			@body = body => Array
		end

		attr_reader :body
	end
end
