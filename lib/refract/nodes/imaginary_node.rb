# frozen_string_literal: true

module Refract
	class ImaginaryNode < Node
		def initialize(numeric:)
			@numeric = numeric
		end

		attr_accessor :numeric
	end
end
