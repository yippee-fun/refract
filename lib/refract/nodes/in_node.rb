# frozen_string_literal: true

module Refract
	class InNode < Node
		def initialize(prism_node: nil, pattern:, statements:)
			@prism_node = prism_node => Prism::Node | nil
			@pattern = pattern
			@statements = statements
			freeze
		end

		attr_accessor :pattern, :statements
	end
end
