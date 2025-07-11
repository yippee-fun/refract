# frozen_string_literal: true

module Refract
	class BeginNode < Node
		def initialize(statements:, rescue_clause:)
			@statements = statements => StatementsNode
			@rescue_clause = rescue_clause => RescueNode
		end

		attr_reader :statements
		attr_reader :rescue_clause
	end
end
