# frozen_string_literal: true

module Refract
	class MultiWriteNode < Node
		def initialize(lefts:, rest:, rights:, value:)
			@lefts = lefts
			@rest = rest
			@rights = rights
			@value = value
		end

		attr_accessor :lefts, :rest, :rights, :value
	end
end
