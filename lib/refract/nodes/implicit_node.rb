# frozen_string_literal: true

module Refract
	class ImplicitNode < Node
		def initialize(value:)
			@value = value => Node
		end

		attr_reader :value
	end
end
