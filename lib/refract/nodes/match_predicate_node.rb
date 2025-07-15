# frozen_string_literal: true

module Refract
	class MatchPredicateNode < Node
		def initialize(value:, pattern:)
			@value = value
			@pattern = pattern
		end

		attr_accessor :value, :pattern
	end
end
