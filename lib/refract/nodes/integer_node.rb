# frozen_string_literal: true

module Refract
	class IntegerNode < Node
		def initialize(value:)
			@value = value
		end

		attr_accessor :value
	end
end
