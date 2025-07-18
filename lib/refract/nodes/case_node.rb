# frozen_string_literal: true

module Refract
	class CaseNode < Node
		def initialize(prism_node: nil, predicate:, conditions:, else_clause:)
			@prism_node = prism_node => Prism::Node | nil
			@predicate = predicate
			@conditions = conditions
			@else_clause = else_clause
			freeze
		end

		attr_accessor :predicate, :conditions, :else_clause
	end
end
