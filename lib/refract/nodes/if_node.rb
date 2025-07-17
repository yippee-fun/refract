# frozen_string_literal: true

module Refract
	class IfNode < Node
		def initialize(prism_node: nil, predicate:, statements:, subsequent:)
			@prism_node = prism_node => Prism::Node | nil
			@predicate = predicate
			@statements = statements
			@subsequent = subsequent
		end

		attr_accessor :predicate, :statements, :subsequent
	end
end
