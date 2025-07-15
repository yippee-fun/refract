# frozen_string_literal: true

module Refract
	class BlockParametersNode < Node
		def initialize(parameters:, locals:)
			@parameters = parameters
			@locals = locals
		end

		attr_accessor :parameters, :locals
	end
end
