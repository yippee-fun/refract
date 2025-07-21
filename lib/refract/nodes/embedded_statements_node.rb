# frozen_string_literal: true

module Refract
	class EmbeddedStatementsNode < Node
		def initialize(prism_node: nil, statements:)
			@prism_node = prism_node => Prism::Node | nil
			@statements = statements
			freeze
		end

		attr_accessor :statements
	end
end
