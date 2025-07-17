# frozen_string_literal: true

module Refract
	class UntilNode < Node
		def initialize(prism_node: nil, predicate:, statements:)
			@prism_node = prism_node => Prism::Node | nil
			@predicate = predicate
			@statements = statements
		end

		attr_accessor :predicate, :statements
	end
end
