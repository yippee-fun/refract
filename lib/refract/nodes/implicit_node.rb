# frozen_string_literal: true

module Refract
	class ImplicitNode < Node
		def initialize(value:)
			@value = value
		end

		attr_accessor :value
	end
end
