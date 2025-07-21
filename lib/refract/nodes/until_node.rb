# frozen_string_literal: true

module Refract
	class UntilNode < Node
		def initialize(prism_node: nil, predicate:, statements:, inline:)
			@prism_node = prism_node => Prism::Node | nil
			@predicate = predicate
			@statements = statements
			@inline = inline
			freeze
		end

		attr_accessor :predicate, :statements, :inline
	end
end
