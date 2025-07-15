# frozen_string_literal: true

module Refract
	class RationalNode < Node
		def initialize(numerator:, denominator:)
			@numerator = numerator
			@denominator = denominator
		end

		attr_accessor :numerator, :denominator
	end
end
