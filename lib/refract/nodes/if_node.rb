# frozen_string_literal: true

module Refract
	class IfNode < Node
		def initialize(prism_node: nil, predicate:, statements: nil, subsequent: nil, inline:)
			@prism_node = prism_node => Prism::Node | nil
			@predicate = predicate
			@statements = statements
			@subsequent = subsequent
			@inline = inline
			freeze
		end

		attr_accessor :predicate, :statements, :subsequent, :inline
	end
end
