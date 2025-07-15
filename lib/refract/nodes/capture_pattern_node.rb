# frozen_string_literal: true

module Refract
	class CapturePatternNode < Node
		def initialize(value:, target:)
			@value = value
			@target = target
		end

		attr_accessor :value, :target
	end
end
