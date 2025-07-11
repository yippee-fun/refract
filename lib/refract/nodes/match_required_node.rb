# frozen_string_literal: true

module Refract
	class MatchRequiredNode < Node
		def initialize(value:, pattern:)
			@value = value => Node
			@pattern = pattern => Node
		end

		attr_reader :value
		attr_reader :pattern
	end
end
