# frozen_string_literal: true

module Refract
	class UnlessNode < Node
		def initialize(prism_node: nil, predicate:, statements:, else_clause:)
			@prism_node = prism_node => Prism::Node | nil
			@predicate = predicate
			@statements = statements
			@else_clause = else_clause
		end

		attr_accessor :predicate, :statements, :else_clause
	end
end
