# frozen_string_literal: true

module Refract
	class WhenNode < Node
		def initialize(prism_node: nil, conditions:, statements:)
			@prism_node = prism_node => Prism::Node | nil
			@conditions = conditions
			@statements = statements
		end

		attr_accessor :conditions, :statements
	end
end
