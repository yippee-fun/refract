# frozen_string_literal: true

module Refract
	class BlockParametersNode < Node
		def initialize(prism_node: nil, parameters:, locals:)
			@prism_node = prism_node => Prism::Node | nil
			@parameters = parameters
			@locals = locals
			freeze
		end

		attr_accessor :parameters, :locals
	end
end
