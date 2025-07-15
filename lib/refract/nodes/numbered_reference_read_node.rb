# frozen_string_literal: true

module Refract
	class NumberedReferenceReadNode < Node
		def initialize(number:)
			@number = number
		end

		attr_accessor :number
	end
end
