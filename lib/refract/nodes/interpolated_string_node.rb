# frozen_string_literal: true

module Refract
	class InterpolatedStringNode < Node
		def initialize(parts:)
			@parts = parts
		end

		attr_accessor :parts
	end
end
