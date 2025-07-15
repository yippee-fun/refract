# frozen_string_literal: true

module Refract
	class InNode < Node
		def initialize(pattern:, statements:)
			@pattern = pattern
			@statements = statements
		end

		attr_accessor :pattern, :statements
	end
end
