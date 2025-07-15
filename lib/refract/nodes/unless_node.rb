# frozen_string_literal: true

module Refract
	class UnlessNode < Node
		def initialize(predicate:, statements:, else_clause:)
			@predicate = predicate
			@statements = statements
			@else_clause = else_clause
		end

		attr_accessor :predicate, :statements, :else_clause
	end
end
