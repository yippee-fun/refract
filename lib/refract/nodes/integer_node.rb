# frozen_string_literal: true

module Refract
	class IntegerNode < Node
		def initialize(value:)
			@value = value => Integer
		end

		attr_reader :value
	end
end
