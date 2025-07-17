# frozen_string_literal: true

module Refract
	class ProgramNode < Node
		def initialize(prism_node: nil, statements:)
			@prism_node = prism_node => Prism::Node | nil
			@statements = statements
		end

		attr_reader :statements
	end
end
