# frozen_string_literal: true

module Refract
	class BeginNode < Node
		def initialize(prism_node: nil, statements:, rescue_clause:, else_clause:, ensure_clause:)
			@prism_node = prism_node => Prism::Node | nil
			@statements = statements
			@rescue_clause = rescue_clause
			@else_clause = else_clause
			@ensure_clause = ensure_clause
			freeze
		end

		attr_accessor :statements, :rescue_clause, :else_clause, :ensure_clause
	end
end
