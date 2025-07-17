# frozen_string_literal: true

module Refract
	class PinnedVariableNode < Node
		def initialize(variable:)
			@variable = variable
		end

		attr_accessor :variable
	end
end
