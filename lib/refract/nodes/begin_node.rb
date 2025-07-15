# frozen_string_literal: true

module Refract
	class BeginNode < Node
		def initialize(statements:, rescue_clause:, else_clause:, ensure_clause:)
			@statements = statements
			@rescue_clause = rescue_clause
			@else_clause = else_clause
			@ensure_clause = ensure_clause
		end

		attr_accessor :statements, :rescue_clause, :else_clause, :ensure_clause
	end
end
