# frozen_string_literal: true

module Refract
	class MultiTargetNode < Node
		def initialize(lefts:, rest:, rights:)
			@lefts = lefts
			@rest = rest
			@rights = rights
		end

		attr_accessor :lefts, :rest, :rights
	end
end
