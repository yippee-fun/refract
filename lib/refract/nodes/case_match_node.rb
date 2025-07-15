# frozen_string_literal: true

module Refract
	class CaseMatchNode < Node
		def initialize(predicate:, conditions:, else_clause:)
			@predicate = predicate
			@conditions = conditions
			@else_clause = else_clause
		end

		attr_accessor :predicate, :conditions, :else_clause
	end
end
