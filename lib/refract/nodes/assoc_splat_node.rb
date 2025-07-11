# frozen_string_literal: true

module Refract
	class AssocSplatNode < Node
		def initialize(value:)
			@value = value => Node
		end

		attr_reader :value
	end
end
