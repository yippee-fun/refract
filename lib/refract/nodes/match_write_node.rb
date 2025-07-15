# frozen_string_literal: true

module Refract
	class MatchWriteNode < Node
		def initialize(call:, targets:)
			@call = call
			@targets = targets
		end

		attr_accessor :call, :targets
	end
end
