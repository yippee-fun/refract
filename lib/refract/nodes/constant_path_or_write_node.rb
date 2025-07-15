# frozen_string_literal: true

module Refract
	class ConstantPathOrWriteNode < Node
		def initialize(target:, value:)
			@target = target
			@value = value
		end

		attr_accessor :target, :value
	end
end
